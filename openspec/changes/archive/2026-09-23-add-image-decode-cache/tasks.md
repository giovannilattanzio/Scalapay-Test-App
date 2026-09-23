# Tasks

## 1. Presentation

- [x] 1.1 [presentation] In `CatalogProductTile`, wrap `Image.network` in a `LayoutBuilder` and pass `cacheWidth` = `maxWidth` × `MediaQuery.devicePixelRatioOf`, rounded, or `null` when `maxWidth` is not finite. Leave `fit`, `loadingBuilder` and `errorBuilder` unchanged (design Decision 1; spec "Product images are held in memory at no more than their display size": "Large image held at display size" and "Image that cannot be loaded"). Verify: `flutter analyze` is clean, and the existing tests in `test/presentation/catalog/` pass without changes.
- [x] 1.2 [presentation] Add an optional `devicePixelRatio` parameter (default `1`) to `pumpApp`, and add a test to `catalog_product_tile_test.dart`. At dpr 3, it checks that `Image.image` is a `ResizeImage` whose `width` equals the `LayoutBuilder`'s width × 3, rounded (design Decision 2; scenario "Large image held at display size"). Verify: `flutter test` is green.

## 2. Verification

- [x] 2.1 [tooling] Verify by hand on an iOS simulator (`flutter run`) that the change does not alter behaviour with today's photos (scenario "Small image left at its own size"). In the DevTools evaluation console, evaluate `PaintingBinding.instance.imageCache.currentSizeBytes` after scrolling the same pages before the change (`git stash`) and after it. Result: 48,600,000 bytes both times for 135 images, that is 360,000 bytes (300×300 px) each, so today's photos are smaller than the image area and are not resized.
