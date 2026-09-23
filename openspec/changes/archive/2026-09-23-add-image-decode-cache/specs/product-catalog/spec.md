# Spec Delta

## ADDED Requirements

### Requirement: Product images are held in memory at no more than their display size
Each product image SHALL be held in memory at no more than the size it is displayed at on the device's screen, whatever its source resolution, so that larger photos from the catalog do not shrink the number of images the in-memory cache can keep while the user scrolls. An image SHALL still render sharp on a high-density screen, and an image smaller than its display area SHALL NOT be enlarged in memory. Images are not kept across app restarts.

#### Scenario: Large image held at display size
- **WHEN** a product card's image area is 160 logical pixels wide on a screen with a pixel density of 3
- **THEN** its image is held in memory at most 480 pixels wide, whatever the source resolution

#### Scenario: Small image left at its own size
- **WHEN** a product's photo is 300 pixels wide and its image area is 440 physical pixels wide
- **THEN** its image is held in memory at 300 pixels wide, as before

#### Scenario: Image that cannot be loaded
- **WHEN** a product's image cannot be loaded
- **THEN** its card still shows the neutral placeholder in the image area, as before
