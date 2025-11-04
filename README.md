# QuickAspects

A lightweight World of Warcraft addon for WoW Classic that provides a minimap icon with a radial flyout menu for quick access to Hunter Aspects.

## Features

- **Minimap Icon**: Dynamically updates to show your currently active Aspect
- **Titan Panel / LDB Support**: Displays a static addon icon (QuickAspects.tga)
- **Radial Flyout Menu**: Click the icon to open a fan of all known Aspects
- **Smart Positioning**: Buttons arrange themselves in a radial pattern around the icon
- **Blizzard-Style UI**: Uses the classic Blizzard tracking border for a native look
- **Auto-Hide in Combat**: Flyout automatically closes when entering combat
- **Configurable**: Geometry settings can be customized via saved variables

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

No external downloads are required for normal use.

## Usage

### Basic Controls
- **Left-click** the minimap icon to open or close the Aspect flyout  
- **Click any Aspect button** to cast that Aspect  
- Flyout automatically closes after casting or when entering combat  

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

## Supported Aspects

- Aspect of the Hawk  
- Aspect of the Monkey  
- Aspect of the Cheetah  
- Aspect of the Pack  
- Aspect of the Beast  
- Aspect of the Wild  

## Known Issues

None currently known.  
If an aspect icon fails to update, it will revert to the default icon until a new aspect is activated.  
Please report any bugs on the project page.

## Version History

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
