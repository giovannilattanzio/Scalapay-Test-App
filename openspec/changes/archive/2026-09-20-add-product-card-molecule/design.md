# Design

## Context

The package `scalapay_ui` has tokens (`ScalapayColors`, `ScalapayTypography`, `ScalapaySpacing` 8/16, `ScalapayRadius` with one value, 10) and eight atoms. Read from the code:

- `ScalapaySearchField` already renders the Figma search bar (node `0:4053`): 55px high white pill with a light border, text starting 17px from the left, round 45px lilac action button with the search icon, `hint` and writable text (`controller`, `onSubmitted`). The Figma screenshot matches it.
- No widget or token covers the card: the image area needs a radius of 20, the store name a text color (`#3A4045`), and the label layout is new.
- `flutter-design-system.md` says "Atoms only: no product card..." and the orchestrator sends cards to the feature's presentation layer. Both must change for the card to live in the package.

Figma reads were rate limited, so the card was measured from the earlier structure dump (card 164x349: image area 164x195, text block padded 8 horizontally and 12 on top) and the screenshot; the radius, the paddings, the split installments, the money format and the store color were then confirmed by the user.

## Goals / Non-Goals

**Goals:**
- One reusable product card whose values are all injected and whose money is formatted for the app's locale.
- Reuse existing tokens and the existing search field; add only what is required.

**Non-Goals:**
- Tap handling, badges, network images, currency conversion, other molecules.

## Decisions

**1. Search bar: reuse, no change.**
The search field is the search bar. No widget, parameter or token is added. A task only re-checks it against Figma when access returns.

**2. Product card as a new molecule in `lib/src/molecules/`.**
Separate from `lib/src/widgets/` (atoms) so the layer of composition is visible; exported through the same barrel. Widgetbook mirrors it in `widgetbook/lib/molecules/`. Alternative: put it in `widgets/`; rejected because the agent rules distinguish atoms from molecules.

**3. The image is a widget; the card formats money.**
The image is a `Widget`, so the caller decides the source (network, asset, memory) and the fit; the card gives it the area minus padding and clips it to the area's radius. Name, store and the two wordings are plain strings from the caller. Price and installment amount are `double`s formatted by the card. Alternative for the image: an `ImageProvider` or URL; rejected because it would tie the card to a loading strategy.

**4. Money: `intl` with the app's locale and an optional currency symbol.**
`NumberFormat.currency(locale: Localizations.localeOf(context).toString(), symbol: currency ?? '', decimalDigits: 2)`; separators and symbol position follow the locale (it: "85,00 €", en: "€85.00"). One `currency` parameter serves both the price and the installment. Alternative: a fixed "85,00€" format; rejected by the user because it ignores the locale. Without a currency the amount is a plain number with two decimals. Adds `intl` to `scalapay_ui`.

**5. Installments: `installmentCount` (`int?`), `installmentAmount` (`double?`), `installmentLabel` (`String?`).**
The line is the count, the label and the formatted amount, in that order, separated by spaces ("3 rate da 23,33 €"). Count and amount come together; when both are set the label is required. All three are asserted at construction (debug builds), as Flutter widgets reject invalid combinations. A label without values shows nothing. Alternative: a template string with placeholders, which would allow other word orders; rejected as more than asked, and left as a follow-up if a language needs it. Nothing about the wording is fixed in the card, so it is not tied to English.

**6. Price connector: optional external string.**
`priceConnector` (`String?`) is shown after the price, on the price line, only when the installments line is shown (the "or" of the design). Without installments the connector is ignored.

**7. Only the parameters the content needs.**
`image`, `name`, `store`, `price`, `currency`, `priceConnector`, `installmentCount`, `installmentAmount`, `installmentLabel`. No `onTap`, no style overrides.

**8. Styles from tokens.**
Name `p3` in `textPrimary` (2 lines, ellipsis); store `p4` in the new `textStoreName`; price line `p4` in `textSecondary`; installments line `p3` in `primary` (wraps). Image area `surface`, radius `image`. Vertical gaps derived from existing spacing (12 = `xs * 1.5`, 4 = `xs / 2`, 8 = `xs`), confirmed as the Figma paddings by the user, so no spacing token is added.

**9. Two new tokens, both confirmed.**
`ScalapayRadius.image = 20` (the existing 10 would differ visibly). `ScalapayColors.textStoreName = #3A4045` (Figma Grayscale/850), which also closes an old gap: the main spec already lists `#3A4045` but the code never had a token for it.

### Contracts

- `ScalapayProductCard({super.key, required Widget image, required String name, required String store, required double price, String? currency, String? priceConnector, int? installmentCount, double? installmentAmount, String? installmentLabel})`, with `assert((installmentCount == null) == (installmentAmount == null))` and `assert(installmentCount == null || installmentLabel != null)`.
- `ScalapayRadius.image -> double` (20); `ScalapayRadius.entries` includes `image`.
- `ScalapayColors.textStoreName -> Color` (`#3A4045`); included in `lerp` and `entries`.
- Layout: `Column(start)`: `AspectRatio(164 / 195)` image area (`surface`, radius `image`, clipped, image centered with `xs` padding); then padding (`xs` horizontal, 12 top) with name, store, an 8 gap, the price line (`"<price>"`, plus `" <priceConnector>"` when the installments line is shown) and, when present, the installments line.
- Barrel: `package:scalapay_ui/scalapay_ui.dart` exports `molecules/molecules.dart`.
- Dependency: `intl` in `packages/scalapay_ui/pubspec.yaml`.
- Widgetbook: use cases for `ScalapayProductCard`: default (knobs for name, store, price, currency, connector, count, amount, label; a placeholder widget as image), long texts, no installments, two cards in a grid row, and one under an Italian locale.

## Risks / Trade-offs

- [Text styles were measured from a screenshot, not read from Figma] -> Re-read node `0:3926` when access returns and adjust values only.
- [The locale comes from the surrounding `Localizations`; a `MaterialApp` without a locale uses English] -> The Widgetbook and tests set the locale explicitly; the app must configure its locale.
- [`assert` only rejects invalid installment combinations in debug builds] -> Same contract as other Flutter widgets; the spec describes the rejection at construction.
- [The wording between count and amount cannot reorder words] -> Enough for "3 rate da 23,33 €" and "3 installments of €23.33"; a template string is the follow-up if needed.
- [The image's fit is the caller's responsibility] -> The card provides bounded constraints; the Widgetbook use case shows `BoxFit.contain`.
- [Molecules in the package change the agent and orchestrator rules] -> Updated in the same change, with the reuse rule made explicit.

## Migration Plan

Additive. No existing widget changes.
