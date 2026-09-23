# Proposal

## Why

Today this change brings no measurable gain, and it is kept as a safeguard. The catalog API currently returns product photos of 300×300 px. Each takes 360 KB decoded, so Flutter's in-memory image cache (100 MB) holds about 290 of them, almost 10 pages of 30 products, before evicting any. On a phone at 3× the card's image area is about 440 physical pixels wide, wider than the photo. Measured on a simulator after scrolling the same pages, the cache held 48.6 MB for 135 images both before and after the change.

The risk it covers is the API starting to return larger photos. Decoded at source resolution, a 1000×1000 photo takes 4 MB, so the cache would hold only about 25 images. The first images would be evicted within a single page and downloaded again whenever the user scrolls back. With the change, the memory per image is bounded by the size of the card on screen, whatever the source.

## What Changes

- Decode each product image at no more than the physical pixel width of the card's image area (`cacheWidth`). Images already smaller than that area are decoded at their own size, as today, so the current 300×300 photos are unaffected.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `product-catalog`: adds a requirement that product images are held in memory at no more than their display size, and are rendered sharp at the screen's pixel density.

### Non-goals

- A disk cache, or keeping images across app restarts. Images are still downloaded once per launch.
- Adding `cached_network_image` or any other dependency.
- Changing the size of Flutter's global `ImageCache`.
- Updating the README.
- Changing the design system: `ScalapayProductCard` already receives its image as a widget from the caller.

## Impact

- Code:
  - `lib/src/presentation/catalog/widgets/catalog_product_tile.dart`: the only production file that changes.
  - `test/presentation/catalog/widgets/catalog_product_tile_test.dart`: gains a new test.
  - `test/helpers/pump_app.dart`: may gain an optional `devicePixelRatio` parameter.
- No new dependencies, no change to the API or the data layer. Existing tests that use `invalid.invalid` URLs keep working as they do today.
