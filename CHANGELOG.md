# Changelog

All notable changes to QuickAspects will be documented in this file.

## [3.3.4] - 11/09/2025

### Fixed
- **Tooltip Rank Display:** Tooltips now correctly show the highest rank of each aspect that the player knows, instead of always showing Rank 1. This affects multi-rank spells like Aspect of the Hawk and Aspect of the Wild.

### Changed
- Added `GetHighestRank()` function to scan the player's spellbook and identify the highest available rank for each aspect.
- Updated `GetKnownAspects()` to use the highest rank spell ID for both casting and tooltip display.

---

## [3.3.3] - 11/09/2025

### Fixed
- **Combat Lockdown Protection:** Added proper combat state check before attempting to show flyout menu. Clicking the minimap icon during combat now displays a friendly error message instead of generating a protected function error.
- **Added nil checks:** Additional safety checks when showing/hiding the flyout to prevent edge case errors.

### Changed
- Added `COMBAT_BLOCK` localization string for the combat error message.

---

## [3.3.2] - 11/03/2025

### Added
- **Static Titan Panel / LDB Icon:** Added support for a permanent addon icon (`QuickAspects.tga`) used by Titan Panel and other LibDataBroker displays.

### Changed
- **Separated Icon Logic:** The minimap button icon is now fully independent from the LibDataBroker icon (Titan Panel no longer changes when Aspects switch).
- **Improved Fallback Handling:** When an active Aspect is cancelled (such as by mounting), the minimap icon now correctly reverts to the default Aspect icon instead of persisting the last one.

### Fixed
- **Mount Cancellation Bug:** Fixed an issue where movement-based Aspects (like Cheetah or Pack) being cancelled by mounting would not visually update on the minimap button.
- **Minor Refactor:** Cleaned up redundant icon updates and improved timer safety during aura changes.

---

## [3.3.1] - 10/25/2025

### Added
- Localization support framework for future translations
- Configurable geometry settings in SavedVariables
- UNIT_AURA event registration for instant aspect change detection
- Aspect scan caching with throttling for better performance
- Comprehensive error handling and nil checks throughout
- Combat lockdown safety for timer management

### Changed
- Improved memory management by reusing textures instead of recreating
- Optimized button setup to only apply mask texture once
- Reduced code duplication in flyout rebuild logic
- Updated alignment calculations for better precision (9.86 → 10.0)
- Enhanced timer cleanup with centralized management

### Fixed
- Potential memory leaks from repeated texture creation
- Missing nil checks for anchor positioning
- Timer cleanup on combat entry
- Aspect icon not updating immediately on buff changes

### Removed
- Right-click hide functionality (use slash commands instead)

---

## [3.3.0] - Initial Release

### Added
- Minimap icon with LibDBIcon support
- Radial flyout menu for aspect selection
- Dynamic icon updates based on active aspect
- Combat auto-hide functionality
- Blizzard-style circular borders with proper alignment
- Slash commands for show/hide
- Support for all WotLK Hunter aspects
