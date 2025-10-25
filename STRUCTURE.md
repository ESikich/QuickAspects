# QuickAspects - Directory Structure

The addon should have the following structure:

```
QuickAspects/
├── QuickAspects.toc
├── QuickAspects.lua
├── README.md
├── CHANGELOG.md
├── STRUCTURE.md
├── LICENSE
└── Libs/
    └── LibDBIcon-1.0/
        ├── LibStub/
        │   └── LibStub.lua
        ├── CallbackHandler-1.0/
        │   └── CallbackHandler-1.0.lua
        ├── LibDataBroker-1.1/
        │   └── LibDataBroker-1.1.lua
        ├── LibDBIcon-1.0.lua
        ├── LibDBIcon-1.0.toc
        └── embeds.xml
```

## Required Libraries

Only one library package is needed:

**LibDBIcon-1.0** - https://www.wowace.com/projects/libdbicon-1-0

LibDBIcon includes all required dependencies:
- LibStub
- CallbackHandler-1.0
- LibDataBroker-1.1

## Packaging Instructions

1. Create the main `QuickAspects` folder
2. Add `QuickAspects.lua` and `QuickAspects.toc` to the root
3. Create a `Libs` subfolder
4. Download LibDBIcon-1.0 from WowAce
5. Extract the entire LibDBIcon-1.0 folder into `Libs/`
6. Verify the paths in `QuickAspects.toc` match the structure above
7. Test in-game with `/reload`
8. Create a .zip file of the entire `QuickAspects` folder for distribution

## Notes

- The Interface version in the TOC (30403) is for WotLK 3.3.5a
- LibDBIcon bundles all its dependencies, so only one download is needed
- End users extract the zip to their `Interface/AddOns/` folder
- The folder MUST be named `QuickAspects` (matching the TOC filename)
- Libraries can also be provided by other addons if already installed

## Testing Checklist

Before release:
- [ ] Addon loads without errors (`/console scriptErrors 1`)
- [ ] Minimap icon appears
- [ ] Left-click opens flyout
- [ ] Aspects cast when clicked
- [ ] Flyout closes in combat
- [ ] Icon updates with active aspect
- [ ] Slash commands work
- [ ] Settings persist after `/reload`
- [ ] No lua errors in various situations
