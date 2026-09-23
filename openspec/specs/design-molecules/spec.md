# design-molecules Specification

## Purpose

Provides composite widgets built only from design system atoms and tokens, whose values come from the caller, so screens can assemble them without repeating layout or styling.

## Requirements

### Requirement: Product card
The design system SHALL provide a product card that shows a product image in a rounded surface area, followed by the product name, the store name, a price line and, when given, an installments line. The image, the name, the store, the price (a number), the currency symbol, the installment number, the installment amount (a number), the installments wording and the price connector SHALL be supplied by the caller. The card SHALL format the price and the installment amount as money with two decimals, using the number conventions of the locale of the surrounding app and the caller's currency symbol, and SHALL NOT otherwise translate or generate text. The card SHALL take the full width its parent offers, keep a fixed proportion for the image area, and take its colors, text styles, spacing and radii from the design tokens.

#### Scenario: Content comes from the caller
- **WHEN** a card is created with an image, a name, a store, a price, and the installment number, amount and wording
- **THEN** it shows that image, the name, the store, the formatted price, and the installments line, and no other text

#### Scenario: Money formatting
- **WHEN** a card is created with price 85 and currency "€" in an app whose locale uses a comma as decimal separator
- **THEN** the price shows two decimals with a comma and the currency symbol, and in an app whose locale uses a period it shows a period

#### Scenario: Currency applies to price and installment
- **WHEN** a card is created with a currency and installment values
- **THEN** both the price and the installment amount show that currency symbol

#### Scenario: No currency
- **WHEN** a card is created without a currency
- **THEN** the price and the installment amount show as plain numbers with two decimals

#### Scenario: Installments line
- **WHEN** a card is created with 3 installments, amount 23.33 and wording "rate da"
- **THEN** its installments line shows the number 3, then "rate da", then the formatted amount, in that order

#### Scenario: No installments
- **WHEN** a card is created with neither the installment number nor the amount
- **THEN** it shows no installments line and no price connector, and its layout has no empty space for them

#### Scenario: Installment values come in pairs
- **WHEN** a card is created with only one of the installment number and the installment amount
- **THEN** the card rejects the combination at construction

#### Scenario: Installments wording is required with the values
- **WHEN** a card is created with both the installment number and amount but no wording
- **THEN** the card rejects the combination at construction

#### Scenario: Price connector
- **WHEN** a card shows an installments line and has a price connector
- **THEN** the connector appears after the price on the price line

#### Scenario: Connector without installments
- **WHEN** a card has a price connector but no installments line
- **THEN** the connector is not shown

#### Scenario: Long name is truncated
- **WHEN** the product name does not fit in two lines
- **THEN** it is cut at the second line with an ellipsis

#### Scenario: Installments wrap
- **WHEN** the installments line does not fit on one line
- **THEN** it continues on a second line

#### Scenario: Image area
- **WHEN** a card is shown
- **THEN** the image is centered in a rounded area with the surface color and the image radius, the image is clipped to that area, and the area keeps the same proportion at any card width

#### Scenario: Card in a grid
- **WHEN** two cards are placed side by side in equal-width columns
- **THEN** each card fills its column

### Requirement: Molecules reuse atoms and foundations
A molecule SHALL be composed from existing atoms and tokens. A molecule SHALL NOT introduce a widget or a token that duplicates an existing one, and SHALL add a parameter only when its content or behavior cannot come from the caller through an existing one.

#### Scenario: Search bar is not duplicated
- **WHEN** a screen needs the catalog search bar
- **THEN** it uses the existing search field with its hint and writable text, and the design system provides no second search widget

### Requirement: Product card is announced as one element
The product card SHALL be exposed to assistive technology as a single element whose label reads, in this order, the product name, the store, the formatted price line and, when shown, the installments line, so a screen reader user hears one product at a time instead of separate fragments. The image area SHALL be treated as decorative and SHALL NOT add its own element or label.

#### Scenario: One element per card
- **WHEN** a card is shown with name "Sneaker", store "Nike", price 85, currency "€" and 3 installments of 28.33 with wording "rate da", in an Italian locale
- **THEN** assistive technology finds one element for the card whose label contains "Sneaker", "Nike", "85,00 €" and "3 rate da 28,33 €" in that order

#### Scenario: Image is not announced
- **WHEN** a card is shown with any image
- **THEN** no separate element is exposed for the image
