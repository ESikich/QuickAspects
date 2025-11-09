# QuickAspects

A lightweight World of Warcraft addon for WoW Classic that provides a minimap icon with a radial flyout menu for quick access to Hunter Aspects.

## Features

- **Minimap Icon**: Dynamically updates to show your currently active Aspect
- **Titan Panel / LDB Support**: Displays a static addon icon (QuickAspects.tga)
- **Radial Flyout Menu**: Click the icon to open a fan of all known Aspects

## Installation

1. Download the addon  
2. Extract to `World of Warcraft/_classic_era_/Interface/AddOns/`  
3. Ensure the folder is named `QuickAspects`  
4. Restart WoW or reload UI (`/reload`)

## Dependencies

This addon requires **LibDBIcon-1.0** (included in the release), which bundles all necessary libraries:
- LibStub  
- CallbackHandler-1.0  
- LibDataBroker-1.1  
- LibDBIcon-1.0  

## Usage

### Basic Controls
- **Left-click** the minimap icon to open or close the Aspect flyout  
- **Click any Aspect button** to cast that Aspect  
- Flyout automatically closes after casting or when entering combat  
- **Note**: The flyout cannot be opened during combat (a message will appear if you try)

### Slash Commands
- `/qaspects show` — Show the minimap icon  
- `/qaspects hide` — Hide the minimap icon  

### Customization

Advanced users can modify geometry settings in the SavedVariables file:
- `buttonSize` — Size of aspect buttons (default: 22)  
- `arcDegrees` — Spread of the radial fan (default: 140)  
- `radiusPad` — Distance from launcher icon (default: 16)  
- `borderThickness` — Gap between icon and border ring (default: 3)  
- `iconInset` — Icon shrink amount (default: 6)  

## Known Issues

None currently known.
Please report any bugs on the project page.

## Version History

### 3.3.4
- Fixed: Tooltips now correctly display the highest rank of each aspect instead of always showing Rank 1  
- Enhanced: Spellbook scanning to automatically detect and use the highest available rank  

### 3.3.3
- Fixed: Combat lockdown protection added to prevent protected function errors  
- Added: Friendly error message when attempting to open flyout during combat  
- Enhanced: Additional nil checks for improved stability  

### 3.3.2
- Fixed: Minimap icon now correctly resets when mounting cancels a movement-based Aspect  
- Added: Static icon for Titan Panel / LDB displays (`QuickAspects.tga`)  
- Internal: Refined event handling and timer cleanup  

### 3.3.1
- Improved error handling and nil checks  
- Optimized aspect scanning performance  
- Added `UNIT_AURA` event for instant buff updates  
- Enhanced combat safety  

### 3.3.0
- Initial release  

## Credits

Created for World of Warcraft: Classic Era / Season of Discovery  
Maintained by the community with love for Hunters everywhere.  

## License

MIT License — See LICENSE file for details.
