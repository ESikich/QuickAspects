# Changelog

All notable changes to QuickAspects will be documented in this file.

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

## [3.3.0] - Initial Release

### Added
- Minimap icon with LibDBIcon support
- Radial flyout menu for aspect selection
- Dynamic icon updates based on active aspect
- Combat auto-hide functionality
- Blizzard-style circular borders with proper alignment
- Slash commands for show/hide
- Support for all WotLK Hunter aspects