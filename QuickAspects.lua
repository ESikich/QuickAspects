-- QuickAspects 3.3.1
-- Minimap icon + radial flyout for Hunter Aspects (LibDataBroker / LibDBIcon)
-- Circular icon + Blizzard "MiniMap-TrackingBorder" with scale-proof, offset-free alignment.
-- Alignment uses intrinsic *art-space* center shifts (texture pixels), scaled at runtime.
-- BORDER_THICKNESS controls the visible gap (ring) between the icon circle and the Blizzard ring.

local ADDON = ...
local f = CreateFrame("Frame")

-- Only load for Hunters
local _, playerClass = UnitClass("player")
if playerClass ~= "HUNTER" then return end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("LEARNED_SPELL_IN_TAB")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterUnitEvent("UNIT_AURA", "player")

------------------------------------------------------------
-- Localization
------------------------------------------------------------
local L = {
  ADDON_NAME = "QuickAspects",
  LEFT_CLICK = "Left-click: open/close aspects",
  ICON_SHOWN = "icon shown",
  ICON_HIDDEN = "icon hidden",
  USAGE = "/qaspects show | hide",
  LDB_MISSING = "LibDataBroker-1.1 missing",
  DBICON_MISSING = "LibDBIcon-1.0 not found.",
}

------------------------------------------------------------
-- Saved Variables (with user-configurable geometry)
------------------------------------------------------------
QuickAspectsDB = QuickAspectsDB or {
  minimap = { hide = false },
  buttonSize = 22,
  arcDegrees = 140,
  radiusPad = 16,
  borderThickness = 3,
  iconInset = 6,
}

local function ensureDB()
  QuickAspectsDB.minimap = QuickAspectsDB.minimap or { hide = false }
  QuickAspectsDB.buttonSize = QuickAspectsDB.buttonSize or 22
  QuickAspectsDB.arcDegrees = QuickAspectsDB.arcDegrees or 140
  QuickAspectsDB.radiusPad = QuickAspectsDB.radiusPad or 16
  QuickAspectsDB.borderThickness = QuickAspectsDB.borderThickness or 3
  QuickAspectsDB.iconInset = QuickAspectsDB.iconInset or 6
end

------------------------------------------------------------
-- Aspect Catalog
------------------------------------------------------------
local ASPECT_IDS = {
  13165,  -- Hawk
  13163,  -- Monkey
  5118,   -- Cheetah
  13159,  -- Pack
  13161,  -- Beast
  20043,  -- Wild (R1)
}

local function GetKnownAspects()
  local known = {}
  for _, id in ipairs(ASPECT_IDS) do
    local name, _, icon = GetSpellInfo(id)
    if name and icon and IsPlayerSpell(id) then
      known[#known+1] = { id = id, name = name, icon = icon }
    end
  end
  table.sort(known, function(a,b) return a.name < b.name end)
  return known
end

------------------------------------------------------------
-- UI State & Tunables
------------------------------------------------------------
local UI = {
  flyout = nil,
  buttons = {},
  pendingRebuild = false,
  minimapHooked = false,
}

-- Icon bleed under its mask to hide square corners
local ICON_OUTSET = 3  -- Fixed value, derived from BORDER_THICKNESS

-- Blizzard border art constants
local BLIZZ_BORDER_INNER = 31  -- inner hole diameter in the art (px)
local BLIZZ_BORDER_SIZE  = 54  -- full texture size (px, square)

-- >>> Intrinsic art-space center shift (texture pixels) <<<
-- The Blizzard MiniMap-TrackingBorder texture has its inner circle offset from the texture center.
-- These values represent where the hole's center sits in texture space.
-- Measured from the actual texture: the hole center is offset approximately:
-- X: +10 pixels right from texture center (54/2 = 27, hole at ~37, so 37-27 = 10)
-- Y: -10 pixels down from texture center (54/2 = 27, hole at ~37, so 27-37 = -10)
local ART_SHIFT_X = 10.0
local ART_SHIFT_Y = -10.0

-- Optional tiny **post-center** screen-pixel nudges
local BORDER_OFFSET_X = 0  -- +right / -left
local BORDER_OFFSET_Y = 0  -- +up    / -down

local function GetMinimapButtonFrame()
  return _G["LibDBIcon10_QuickAspects"]
end

------------------------------------------------------------
-- Icon paths
------------------------------------------------------------
-- Static icon for Titan Panel / LDB displays
local titanPanelIcon = "Interface\\AddOns\\QuickAspects\\QuickAspects"

-- Fallback icon for the MINIMAP BUTTON when no aspect is active
local aspectIconFallback = "Interface\\AddOns\\QuickAspects\\QuickAspects"

------------------------------------------------------------
-- Timer Management
------------------------------------------------------------
local timers = { pending = nil, clear = nil }

local function CancelTimer(key)
  if timers[key] and timers[key].Cancel then
    timers[key]:Cancel()
    timers[key] = nil
  end
end

local function CancelAllTimers()
  for k in pairs(timers) do
    CancelTimer(k)
  end
end

------------------------------------------------------------
-- Aspect Detection → Minimap Icon
------------------------------------------------------------
local ASPECT_NAME_TO_ICON = {}
local function BuildAspectNameMap()
  wipe(ASPECT_NAME_TO_ICON)
  for _, id in ipairs(ASPECT_IDS) do
    local name, _, icon = GetSpellInfo(id)
    if name and icon then ASPECT_NAME_TO_ICON[name] = icon end
  end
end

-- Only changes the LibDBIcon minimap button, not the LDB object.
local function SetMinimapIconTexture(tex)
  local btn = GetMinimapButtonFrame()
  if btn and btn.icon then
    btn.icon:SetTexture(tex or aspectIconFallback)
    btn.icon:SetAlpha(1)
    btn:SetAlpha(1)
  end
end

-- Caching for performance
local aspectCache = { icon = nil, lastScan = 0 }
local SCAN_THROTTLE = 0.1 -- seconds

local function ScanActiveAspectIcon()
  local now = GetTime()
  if now - aspectCache.lastScan < SCAN_THROTTLE then
    return aspectCache.icon
  end
  aspectCache.lastScan = now
  
  for i = 1, 40 do
    local name = UnitBuff("player", i)
    if not name then break end
    local icon = ASPECT_NAME_TO_ICON[name]
    if icon then
      aspectCache.icon = icon
      return icon
    end
  end
  aspectCache.icon = nil
  return nil
end

local lastConfirmedIcon, pendingAspectIcon = nil, nil

local function ApplyBestIcon()
  local aura = ScanActiveAspectIcon()
  if aura then
    CancelTimer("clear")
    SetMinimapIconTexture(aura)
    lastConfirmedIcon = aura
    return
  end
  if pendingAspectIcon then
    SetMinimapIconTexture(pendingAspectIcon)
    CancelTimer("pending")
    timers.pending = C_Timer.NewTimer(0.35, ApplyBestIcon)
    return
  end

  -- When no aspect buff is active anymore (e.g. cancelled by mounting),
  -- fall back to the generic aspect icon instead of reusing lastConfirmedIcon.
  CancelTimer("clear")
  timers.clear = C_Timer.NewTimer(0.6, function()
    local again = ScanActiveAspectIcon()
    if again then
      SetMinimapIconTexture(again)
      lastConfirmedIcon = again
    else
      lastConfirmedIcon = nil
      SetMinimapIconTexture(aspectIconFallback)
    end
  end)
end

------------------------------------------------------------
-- Flyout: creation & layout
------------------------------------------------------------
local function EnsureFlyout()
  if UI.flyout then return UI.flyout end
  local fly = CreateFrame("Frame", "QuickAspectsFlyout", UIParent)
  UI.flyout = fly
  fly:SetFrameStrata("FULLSCREEN_DIALOG")
  fly:SetClampedToScreen(true)
  fly:SetSize(10,10)
  fly:Hide()
  fly:EnableMouse(false)
  tinsert(UISpecialFrames, "QuickAspectsFlyout")
  UI.buttons = {}
  return fly
end

local function SetupButton(b, data)
  local BTN_SIZE = QuickAspectsDB.buttonSize
  local BORDER_THICKNESS = QuickAspectsDB.borderThickness
  local ICON_INSET = QuickAspectsDB.iconInset
  
  b:SetSize(BTN_SIZE, BTN_SIZE)
  b:EnableMouse(true)

  -- ICON (circular via mask) - reuse existing textures
  b.icon = b.icon or b:CreateTexture(nil, "ARTWORK")
  b.icon:ClearAllPoints()

  -- Combine both knobs: ICON_OUTSET expands, ICON_INSET shrinks.
  b.icon:SetPoint("TOPLEFT",  -ICON_OUTSET + ICON_INSET,  ICON_OUTSET - ICON_INSET)
  b.icon:SetPoint("BOTTOMRIGHT", ICON_OUTSET - ICON_INSET, -ICON_OUTSET + ICON_INSET)
  b.icon:SetTexture(data.icon)

  local innerDiam = math.max(2, BTN_SIZE - 2 * BORDER_THICKNESS)
  b.iconMask = b.iconMask or b:CreateMaskTexture()
  b.iconMask:ClearAllPoints()
  b.iconMask:SetPoint("CENTER", b, "CENTER")
  b.iconMask:SetSize(innerDiam, innerDiam)
  b.iconMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
                        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  
  -- Only add mask once
  if not b.maskApplied then
    b.icon:AddMaskTexture(b.iconMask)
    b.maskApplied = true
  end

  -- BLIZZARD BORDER (center-anchored; art-space shifts scaled to screen)
  local s          = BTN_SIZE / BLIZZ_BORDER_INNER
  local borderSize = math.floor(BLIZZ_BORDER_SIZE * s + 0.5)
  local ox_center  = math.floor(ART_SHIFT_X * s + 0.5) + BORDER_OFFSET_X
  local oy_center  = math.floor(ART_SHIFT_Y * s + 0.5) + BORDER_OFFSET_Y

  b.border = b.border or b:CreateTexture(nil, "OVERLAY")
  b.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  b.border:ClearAllPoints()
  b.border:SetPoint("CENTER", b, "CENTER", ox_center, oy_center)
  b.border:SetSize(borderSize, borderSize)

  -- SECURE CAST + UX
  b:SetAttribute("type", "spell")
  b:SetAttribute("spell", data.name)
  b.spellID = data.id

  b:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetSpellByID(self.spellID)
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)
  b:SetScript("PostClick", function()
    if UI.flyout and UI.flyout:IsShown() then UI.flyout:Hide() end
  end)
end

local function LayoutRadial(aspects)
  local BTN_SIZE = QuickAspectsDB.buttonSize
  local ARC_DEGREES = QuickAspectsDB.arcDegrees
  local RADIUS_PAD = QuickAspectsDB.radiusPad
  
  local fly = EnsureFlyout()
  local anchor = GetMinimapButtonFrame()
  
  -- Safety check for anchor
  if not anchor or not anchor:IsVisible() then
    anchor = UIParent
  end
  
  fly:ClearAllPoints()
  fly:SetPoint("CENTER", anchor, "CENTER")

  local count = #aspects
  if count == 0 then return end

  -- Safety checks for positioning
  local mx, my = Minimap:GetCenter()
  local bx, by = anchor:GetCenter()
  if not mx or not my or not bx or not by then
    return -- Bail out if positioning fails
  end

  local base = math.atan2(by - my, bx - mx)
  local ARC = math.rad(ARC_DEGREES)
  local R = BTN_SIZE + RADIUS_PAD
  if count == 1 then ARC = 0 end

  for i = 1, count do
    local t = (count == 1) and 0 or ((i-1)/(count-1))
    local ang = base + (-ARC/2 + t * ARC)
    local x, y = math.cos(ang)*R, math.sin(ang)*R

    local b = UI.buttons[i]
    if b then
      b:ClearAllPoints()
      b:SetPoint("CENTER", anchor, "CENTER", x, y)
      b:Show()
    end
  end

  for j = count+1, #UI.buttons do
    if UI.buttons[j] then UI.buttons[j]:Hide() end
  end
end

local function RebuildFlyout()
  if InCombatLockdown() then
    UI.pendingRebuild = true
    return
  end
  
  local aspects = GetKnownAspects()
  EnsureFlyout()
  
  -- Create/update buttons
  for i, data in ipairs(aspects) do
    local b = UI.buttons[i] or CreateFrame("Button", 
      "QuickAspectsButton"..i, UI.flyout, "SecureActionButtonTemplate")
    UI.buttons[i] = b
    SetupButton(b, data)
  end
  
  -- Hide extras
  for j = #aspects + 1, #UI.buttons do
    if UI.buttons[j] then UI.buttons[j]:Hide() end
  end
  
  -- Single layout call
  LayoutRadial(aspects)
end

------------------------------------------------------------
-- Combat Close + Minimap Hook
------------------------------------------------------------
if Minimap and not UI.minimapHooked then
  UI.minimapHooked = true
  Minimap:HookScript("OnSizeChanged", function()
    if UI.flyout and UI.flyout:IsShown() then
      LayoutRadial(GetKnownAspects())
    end
  end)
end

local combatClose = CreateFrame("Frame")
combatClose:RegisterEvent("PLAYER_REGEN_DISABLED")
combatClose:SetScript("OnEvent", function()
  if UI.flyout and UI.flyout:IsShown() then
    UI.flyout:Hide()
  end
  CancelAllTimers()
end)

------------------------------------------------------------
-- LibDataBroker / LibDBIcon
------------------------------------------------------------
local function makeDataObject()
  local ldb = LibStub and LibStub("LibDataBroker-1.1", true)
  if not ldb then return nil, L.LDB_MISSING end
  
  local dataObj = ldb:NewDataObject("QuickAspects", {
    type = "launcher",
    icon = titanPanelIcon,  -- Titan Panel & other LDB displays use this, static
    OnClick = function(_, button)
      if button == "LeftButton" then
        EnsureFlyout()
        if UI.flyout:IsShown() then
          UI.flyout:Hide()
          return
        end
        RebuildFlyout()
        UI.flyout:Show()
        LayoutRadial(GetKnownAspects())
      end
    end,
    OnTooltipShow = function(tt)
      tt:AddLine(L.ADDON_NAME)
      tt:AddLine(L.LEFT_CLICK, 1, 1, 1)
    end,
  })
  return dataObj
end

local function registerIcon()
  local icon = LibStub and LibStub("LibDBIcon-1.0", true)
  if not icon then
    print("|cffff0000"..L.ADDON_NAME..":|r "..L.DBICON_MISSING)
    return
  end
  
  local dataObj, err = makeDataObject()
  if not dataObj then
    print("|cffff0000"..L.ADDON_NAME..":|r "..(err or "Unknown LDB error"))
    return
  end
  
  icon:Register("QuickAspects", dataObj, QuickAspectsDB.minimap)
  if QuickAspectsDB.minimap.hide then
    icon:Hide("QuickAspects")
  end
  
  C_Timer.After(0.25, function()
    BuildAspectNameMap()
    ApplyBestIcon()
  end)
end

------------------------------------------------------------
-- Slash Commands
------------------------------------------------------------
SLASH_QUICKASPECTS1, SLASH_QUICKASPECTS2 = "/qaspects", "/quickaspects"
SlashCmdList["QUICKASPECTS"] = function(msg)
  msg = (msg or ""):lower()
  local icon = LibStub and LibStub("LibDBIcon-1.0", true)
  
  if msg == "show" and icon then
    QuickAspectsDB.minimap.hide = false
    icon:Show("QuickAspects")
    print("|cff00ff00"..L.ADDON_NAME..":|r "..L.ICON_SHOWN)
  elseif msg == "hide" and icon then
    QuickAspectsDB.minimap.hide = true
    icon:Hide("QuickAspects")
    print("|cff00ff00"..L.ADDON_NAME..":|r "..L.ICON_HIDDEN)
  else
    print("|cff00ff00"..L.ADDON_NAME..":|r "..L.USAGE)
  end
end

------------------------------------------------------------
-- Events
------------------------------------------------------------
f:SetScript("OnEvent", function(_, evt, arg1)
  if evt == "ADDON_LOADED" and arg1 == ADDON then
    ensureDB()
  elseif evt == "PLAYER_LOGIN" then
    registerIcon()
    RebuildFlyout()
  elseif evt == "LEARNED_SPELL_IN_TAB" then
    RebuildFlyout()
  elseif evt == "PLAYER_REGEN_ENABLED" then
    if UI.pendingRebuild then
      UI.pendingRebuild = false
      RebuildFlyout()
    end
  elseif evt == "UNIT_AURA" and arg1 == "player" then
    ApplyBestIcon()
  end
end)
