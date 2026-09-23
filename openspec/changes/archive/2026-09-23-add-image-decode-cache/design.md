# Design

## Context

- `CatalogProductTile` (`lib/src/presentation/catalog/widgets/catalog_product_tile.dart`) passes `Image.network(product.imageUrl, fit: BoxFit.contain, loadingBuilder, errorBuilder)` to `ScalapayProductCard.image`.
- The card puts the image inside `AspectRatio(164/195) > ClipRRect > ColoredBox > Padding(spacing.xs) > Center(child: image)`. `Center` passes loose constraints, so the image widget gets a finite `maxWidth` equal to the width of the area inside the padding.
- The width of the grid cells depends on the screen width and the text scale (`CatalogProductGrid._cellWidth`). The tile does not know that width and should not duplicate the formula.
- `pumpApp` (`test/helpers/pump_app.dart`) sets `devicePixelRatio = 1`.

For the motivation, see proposal.md (Why). For the required behaviour, see `specs/product-catalog/spec.md`.

## Goals / Non-Goals

**Goals:**
- Hold each image in memory at the physical width of its display area, computed at layout time.
- Keep today's placeholder behaviour for loading and errors unchanged.

**Non-Goals:**
- A persistent cache, a new dependency, or tuning of the global `ImageCache`. These are listed in the proposal's Non-goals.
- Any change to `packages/scalapay_ui`.

## Decisions

### 1. `cacheWidth` computed with a `LayoutBuilder` inside the tile
The contract in `CatalogProductTile.build`:

```dart
image: LayoutBuilder(
  builder: (context, constraints) => Image.network(
    product.imageUrl,
    fit: BoxFit.contain,
    cacheWidth: _cacheWidth(constraints.maxWidth, MediaQuery.devicePixelRatioOf(context)),
    loadingBuilder: ..., // unchanged
    errorBuilder: ...,   // unchanged
  ),
),

/// Physical width of the image area, or null when the width is unbounded
/// (the image is then decoded at its source size, as it is today).
static int? _cacheWidth(double maxWidth, double devicePixelRatio) =>
    maxWidth.isFinite ? (maxWidth * devicePixelRatio).round() : null;
```

- **Width only, no `cacheHeight`.** `ResizeImage` with only a width keeps the aspect ratio. With `BoxFit.contain`, the area's width is an upper bound on the pixels needed in every case: a landscape image is limited by the width, and a portrait image by the height, which needs even fewer pixels horizontally.
- **No upscaling.** `Image.network` builds the provider with `ResizeImage.resizeIfNeeded`, whose `allowUpscaling` is `false`. A source image smaller than `cacheWidth` is decoded at its own size.
- **Cache key.** `ResizeImage` includes the width in its key. If the width changes (rotation, a different text scale, a different column count), the image is decoded again under a new key. This is correct and rare.
- **`MediaQuery.devicePixelRatioOf`** instead of `MediaQuery.of(context)`, so the tile does not rebuild on every unrelated `MediaQuery` change.
- Alternatives rejected:
  - Receive `cellWidth` from `CatalogProductGrid`: this couples the tile to the grid's formula and ignores the card's padding.
  - A fixed `cacheWidth` (for example 600): it would be blurry on wide cells or tablets and wasteful on small phones.
  - `cached_network_image` with `memCacheWidth`: it adds native dependencies and forces changes to about ten tests (see proposal.md, Non-goals).

### 2. Test through the `ImageProvider`
The new test in `catalog_product_tile_test.dart`:
- Renders the tile at a known width with `devicePixelRatio` 3.
- Reads `tester.widget<Image>(find.byType(Image)).image`.
- Checks that it is a `ResizeImage` whose `width` equals the width of the `LayoutBuilder` (measured with `tester.getSize` on the `LayoutBuilder`) × 3, rounded.

To set the pixel density, `pumpApp` gains an optional `double devicePixelRatio = 1` parameter that replaces the hardcoded `1`. The default keeps every existing test as it is.

The "Small image left at its own size" scenario is guaranteed by `ResizeImage.resizeIfNeeded` (`allowUpscaling: false`) and was confirmed on a simulator with the current 300×300 photos: the cache held the same bytes before and after the change (see tasks 2.1).

## Risks / Trade-offs

- [The in-memory cache can still fill up after thousands of products] → Accepted. Eviction is LRU and only affects the images furthest from the viewport. The size of the global cache is not a goal.
- [An image is decoded twice if the width changes during the first layout] → The width of a grid cell is stable once laid out. A rotation causes one extra decode, which is accepted.
- [Images still download at every launch] → Accepted (proposal.md, Non-goals).
- [With today's 300×300 photos the change has no effect, so it adds code with no current benefit] → Accepted as a safeguard against larger photos (proposal.md, Why). The code is one `LayoutBuilder` in one widget.
