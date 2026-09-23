# Spec Delta

## ADDED Requirements

### Requirement: Product card is announced as one element
The product card SHALL be exposed to assistive technology as a single element whose label reads, in this order, the product name, the store, the formatted price line and, when shown, the installments line, so a screen reader user hears one product at a time instead of separate fragments. The image area SHALL be treated as decorative and SHALL NOT add its own element or label.

#### Scenario: One element per card
- **WHEN** a card is shown with name "Sneaker", store "Nike", price 85, currency "€" and 3 installments of 28.33 with wording "rate da", in an Italian locale
- **THEN** assistive technology finds one element for the card whose label contains "Sneaker", "Nike", "85,00 €" and "3 rate da 28,33 €" in that order

#### Scenario: Image is not announced
- **WHEN** a card is shown with any image
- **THEN** no separate element is exposed for the image
