# Spec Delta

## Purpose

Defines how the app talks to the Scalapay catalog service: the search request it sends, how a response becomes the products the rest of the app works with, and how every way the call can go wrong becomes a typed failure.

## ADDED Requirements

### Requirement: Product search request
The app SHALL search products through the catalog service's product search endpoint at `https://catalog-api.dev-cat.scalapay.com/v1/products/search`, sending the search text, the requested page, the requested page size, the partner identity of this app (`partnerId=scalapayappit`, `source=trovaprezzi`), the country `IT`, and the language of the active app locale. The page, the page size and the language SHALL be parameters of a search, defaulting to page 1, 30 results and Italian; the partner identity and the country identify the app rather than a search and SHALL be fixed. The base address and the parameter names SHALL be defined in one place rather than repeated at call sites.

#### Scenario: Request carries the query and the fixed parameters
- **WHEN** the app searches for "nike"
- **THEN** it calls the product search endpoint with the search text "nike", page 1, a page size of 30, partner `scalapayappit`, source `trovaprezzi` and country `IT`

#### Scenario: Language follows the app locale
- **WHEN** the app language is English
- **THEN** the request asks the catalog service for English content

#### Scenario: Page and page size can be varied
- **WHEN** a search is made for page 3 with a page size of 10
- **THEN** the request carries page 3 and a page size of 10, and the partner identity and country are unchanged

### Requirement: Sort is expressed as a sort type and a direction
An ordering SHALL be expressed as the pair of a sort type and a direction, and SHALL be sent to the service as that type's field followed by that direction. The only sort types SHALL be text relevance and selling price, the only two the service honours; the app SHALL NOT send any other sort field, because the service accepts an unknown field silently and answers in relevance order, which would misreport the ordering rather than fail. A search with no explicit ordering SHALL ask for text relevance descending.

#### Scenario: Price ascending
- **WHEN** the app searches with sort type selling price and direction ascending
- **THEN** the request asks the service to sort by selling price ascending

#### Scenario: Price descending
- **WHEN** the app searches with sort type selling price and direction descending
- **THEN** the request asks the service to sort by selling price descending

#### Scenario: Direction is carried by the pair, not by the sort type
- **WHEN** the same sort type is searched once ascending and once descending
- **THEN** the two requests differ only in the direction part of the sort parameter

#### Scenario: No explicit ordering
- **WHEN** the app searches with no ordering chosen
- **THEN** the request asks the service for text relevance descending

#### Scenario: Only honoured fields are sendable
- **WHEN** the set of sort types the app can express is inspected
- **THEN** it contains only text relevance and selling price, so no request can ask for a field the service would ignore

### Requirement: The end of the results is derived from the products received
The service reports no total, never returns a short or empty page, and answers with the first page again once its pages are exhausted. The app SHALL therefore treat a page that contains no product it has not already received as the end of the results, SHALL discard the products in it, and SHALL stop requesting further pages. A page that contains both new and already-received products SHALL contribute only the new ones. The app SHALL also stop on a page shorter than the requested page size, and SHALL stop unconditionally after a fixed maximum number of pages, so that the sequence always terminates.

#### Scenario: A page of entirely known products ends the results
- **WHEN** a requested page contains only products already received
- **THEN** the results are complete, nothing from that page is kept, and no further page is requested

#### Scenario: Partial overlap contributes only the new products
- **WHEN** a requested page contains some products already received and some not
- **THEN** only the ones not yet received are kept, and the results are not yet complete

#### Scenario: A short page ends the results
- **WHEN** a requested page contains fewer products than the requested page size
- **THEN** the results are complete after keeping that page's new products

#### Scenario: The sequence always terminates
- **WHEN** the service keeps answering with products never seen before
- **THEN** the app stops requesting pages once it has requested the fixed maximum

#### Scenario: Pages are requested in order
- **WHEN** the app has received the first page and asks for more
- **THEN** it requests the second page, then the third, without skipping or repeating a page number

### Requirement: Price bounds are sent only when set
A search with a minimum or a maximum price SHALL send that bound to the service. A bound that is not set SHALL be omitted from the request rather than sent empty or as a default number.

#### Scenario: Both bounds
- **WHEN** the app searches with a minimum of 100 and a maximum of 200
- **THEN** the request carries both bounds

#### Scenario: One bound
- **WHEN** the app searches with a minimum of 100 and no maximum
- **THEN** the request carries the minimum and no maximum

#### Scenario: No bounds
- **WHEN** the app searches with no price filter
- **THEN** the request carries neither bound

### Requirement: Response becomes products
A successful response SHALL yield the list of products it contains, in the order the service returned them, together with the page it reports. Each product SHALL carry its identifier, name, store name, brand, image address, selling price and list price. A response reporting no matches SHALL yield an empty list, not a failure.

The response SHALL be read as one document, so a product whose required fields are missing or of the wrong type makes the whole response unreadable and fails the search. A partially read response SHALL NOT be reported as a success: the user sees the error state and can retry, rather than a silently short list they cannot tell from a genuine one.

No total SHALL be carried out of this layer. The service's count field equals the number of items returned rather than the number of matches, so there is no total to report.

#### Scenario: Products in service order
- **WHEN** the service returns three products
- **THEN** the search yields those three products in the same order, each with its identifier, name, store, brand, image address, selling price and list price

#### Scenario: The page is carried and no total is
- **WHEN** a search succeeds
- **THEN** the result carries the page the service reported, and carries no count of total matches

#### Scenario: No matches
- **WHEN** the service reports zero matches
- **THEN** the search succeeds with an empty list of products

#### Scenario: One malformed product fails the whole search
- **WHEN** one product in an otherwise valid response is missing a required field
- **THEN** the search reports a parsing failure and yields no products, rather than yielding the readable ones

#### Scenario: Unreadable response
- **WHEN** the response is not in the shape the endpoint documents
- **THEN** the search reports a parsing failure

### Requirement: Failures are typed and carry a reason
Every failed search SHALL report a failure rather than raising out of the data layer, and the failure SHALL distinguish a connectivity or timeout problem from an error answer of the service and from an unreadable response. The failure SHALL carry enough information for the screen to show a message and offer a retry, and SHALL NOT leak transport details to the presentation layer.

#### Scenario: No connectivity
- **WHEN** the device cannot reach the service, or the call times out
- **THEN** the search reports a network failure

#### Scenario: Service error answer
- **WHEN** the service answers with an error status
- **THEN** the search reports a server failure carrying that status

#### Scenario: Unreadable payload
- **WHEN** the answer cannot be read as the documented shape
- **THEN** the search reports a parsing failure

#### Scenario: Nothing escapes the data layer
- **WHEN** the underlying client raises for any reason
- **THEN** the caller receives a failure result and no exception propagates
