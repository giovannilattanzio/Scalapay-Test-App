# Spec Delta

## Purpose

Keeps a written description of the catalog service's HTTP contract inside the repository, because the service publishes none, so that the request shape, the response shape and the service's measured quirks have one authoritative record instead of living in prose.

## ADDED Requirements

### Requirement: The contract is described as an OpenAPI document
The repository SHALL contain an OpenAPI 3 document describing the catalog service, and that document SHALL be the source from which the client is generated. It SHALL declare the service address and SHALL describe the product search operation with a stable operation identifier and a tag, so that the generated client exposes a predictable class and method name. It SHALL describe only operations the service actually serves.

#### Scenario: The document is valid
- **WHEN** the document is validated against the OpenAPI 3 schema
- **THEN** validation passes with no errors

#### Scenario: Only real operations are described
- **WHEN** the document's paths are listed
- **THEN** it describes the product search operation and nothing else, because every other path on the service answers with the gateway's authentication error

#### Scenario: Only a reachable host is declared
- **WHEN** the document's servers are listed
- **THEN** it declares only the host the application can actually call, and a known but unreachable alternative host is absent from the document and explained in the project documentation instead of being described with a guessed authentication scheme

#### Scenario: Generation is reproducible
- **WHEN** the client is generated twice from the same document with no change in between
- **THEN** the produced sources are identical

### Requirement: Every request parameter is described
The document SHALL describe each query parameter the search operation accepts: the search text, the page, the page size, the sort, the price bounds, the unused filter parameter, and the four parameters identifying the calling application and its market. Each SHALL carry its type, and those with a known default SHALL declare it. A parameter that is optional SHALL be described as optional, so that the generated client can omit it rather than send an empty value.

#### Scenario: The search text is required
- **WHEN** the search operation's parameters are inspected
- **THEN** the search text is required and typed as a string

#### Scenario: Paging parameters carry their defaults
- **WHEN** the page and page size parameters are inspected
- **THEN** both are integers and declare the defaults 1 and 30

#### Scenario: Price bounds are optional
- **WHEN** the price bound parameters are inspected
- **THEN** both are optional numbers, so a request can carry one, both or neither

#### Scenario: The sort parameter documents its accepted values
- **WHEN** the sort parameter is inspected
- **THEN** its description states that only text relevance and selling price are honoured, and that any other field is accepted and ignored by the service

### Requirement: The response shape is described in full
The document SHALL describe the response as the service returns it, including the grouping wrapper around each product, the product itself with every field the service sends, the facet counts and the merchant detected from the query. Monetary and numeric fields the service sends sometimes as whole numbers and sometimes as decimals SHALL be typed as numbers, so that a generated client accepts both without failing.

#### Scenario: Products are reached through the grouping wrapper
- **WHEN** the response schema is inspected
- **THEN** it describes a list of groups, each holding a list of hits, each holding one product document

#### Scenario: Prices accept whole numbers and decimals
- **WHEN** a response is parsed in which one product's selling price is a whole number and another's has decimals
- **THEN** both parse successfully into the same numeric type

#### Scenario: Optional parts of the response are optional
- **WHEN** a response arrives without the merchant detected from the query, or with empty facet statistics
- **THEN** it parses successfully

### Requirement: Measured service behaviour is recorded in the document
The document SHALL record, as descriptions on the affected fields and operations, the behaviours this project measured that a reader could not infer from the shapes alone: that only selling price is honoured for ordering, that an unknown sort field is accepted and ignored rather than rejected, that the reported result count equals the number of items returned and is therefore not a total, and that requesting a page past the last one returns the first page again instead of an empty page.

#### Scenario: The result count is documented as not a total
- **WHEN** the response's result count field is inspected
- **THEN** its description states that it equals the number of items returned and cannot be used as a total

#### Scenario: The paging quirk is documented
- **WHEN** the page parameter is inspected
- **THEN** its description states that a page past the last one returns the first page again, so a client must detect the end from the items it has already received

### Requirement: The document is kept honest by a test
A test SHALL parse a response captured from the live service through the types generated from the document, so that a divergence between the document and the service is caught offline rather than at runtime. The test SHALL NOT perform network access.

#### Scenario: The captured response round-trips
- **WHEN** the test parses the captured response through the generated types
- **THEN** parsing succeeds and the products, their prices and their store names match the captured values

#### Scenario: No network in tests
- **WHEN** the test suite runs with no network access
- **THEN** it passes
