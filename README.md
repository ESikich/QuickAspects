# QuickAspects

A lightweight World of Warcraft addon for WoW Classic that provides a minimap icon with a radial flyout menu for quick access to Hunter Aspects.

## Features

- **Minimap Icon**: Shows your currently active aspect
- **Radial Flyout Menu**: Click the icon to open a fan of all known aspects
- **Smart Positioning**: Buttons arrange themselves in a radial pattern around the icon
- **Blizzard-Style UI**: Uses the classic Blizzard tracking border for a native look
- **Auto-Hide in Combat**: Flyout automatically closes when entering combat
- **Configurable**: Geometry settings can be customized via saved variables

## Installation

1. Download the addon
2. Extract to `World of Warcraft/Interface/AddOns/`
3. Ensure the folder is named `QuickAspects`
4. Restart WoW or reload UI (`/reload`)

## Dependencies

This addon requires LibDBIcon-1.0 (included in release), which bundles all necessary libraries:
- LibStub
- CallbackHandler-1.0
- LibDataBroker-1.1
- LibDBIcon-1.0

## Usage

### Basic Controls
- **Left-click** the minimap icon to open/close the aspect flyout
- **Click any aspect button** to cast that aspect
- Flyout automatically closes when casting an aspect or entering combat

### Slash Commands
- `/qaspects show` - Show the minimap icon
- `/qaspects hide` - Hide the minimap icon

### Customization

Advanced users can modify geometry settings in the SavedVariables file:
- `buttonSize` - Size of aspect buttons (default: 22)
- `arcDegrees` - Spread of the radial fan (default: 140)
- `radiusPad` - Distance from launcher icon (default: 16)
- `borderThickness` - Gap between icon and border ring (default: 3)
- `iconInset` - Icon shrink amount (default: 6)

## Supported Aspects

- Aspect of the Hawk
- Aspect of the Monkey
- Aspect of the Cheetah
- Aspect of the Pack
- Aspect of the Beast
- Aspect of the Wild

## Known Issues

None at this time. Please report any bugs on the project page.

## Version History

### 3.3.1
- Improved error handling and nil checks
- Performance optimizations with aspect scan caching
- Better memory management for textures
- Added UNIT_AURA event for instant buff updates
- Improved timer management
- Reduced code duplication
- Enhanced combat safety
- Fixed alignment calculations

### 3.3.0
- Initial release

## Credits

Created for World of Warcraft: Classic (Season of Discovery)

## License

All rights reserved. This addon is provided as-is for personal use.