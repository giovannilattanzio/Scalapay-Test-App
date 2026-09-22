# product-catalog Specification

## Purpose

Lets a shopper find products in the Scalapay catalog from a single screen: typing a search, narrowing the results by price, reordering them, and seeing at a glance what each product costs both in full and in instalments.

## Requirements

### Requirement: Catalog screen layout
The catalog screen SHALL be the app's start screen and SHALL show, from top to bottom: a section title, a search field, a row holding a filters control and a sort control aligned to the trailing edge, and the results area. The title, the search field **and the filters and sort controls** SHALL stay in place while the results area scrolls: only the results move. The controls that change what the results are SHALL remain reachable at any scroll position, without scrolling back to the top. The screen SHALL be built from the design system's components and tokens and SHALL NOT hardcode colors, text styles, spacing or radii.

#### Scenario: Screen is the start destination
- **WHEN** the app is launched
- **THEN** the catalog screen is shown

#### Scenario: Header stays while results scroll
- **WHEN** the user scrolls the results
- **THEN** the title, the search field and the filters and sort controls all remain visible, and only the results area moves

#### Scenario: Filtering and sorting stay reachable deep in the list
- **WHEN** the user has scrolled far enough that the first products are off screen
- **THEN** the filters and sort controls are still on screen and usable

#### Scenario: Controls order
- **WHEN** the screen is shown
- **THEN** the filters control precedes the sort control, and both sit at the trailing edge of their row

### Requirement: Results are shown as a product grid
Results SHALL be shown as a grid of product cards, two columns wide on a phone, using the design system's product card. Each card SHALL show the product image, the product name, the store name, the selling price and an instalments line for three instalments of a third of the selling price, each amount formatted as money in the active locale with the euro symbol. The grid SHALL add more columns instead of stretching the cards when the screen is wider, and SHALL keep the cards legible down to the smallest supported phone width without overflowing.

#### Scenario: Card content
- **WHEN** a product with name, store, image and selling price 85.00 is shown
- **THEN** its card shows that name, that store, that image, the price 85.00 and an instalments line for 3 instalments of 28.33

#### Scenario: Two columns on a phone
- **WHEN** the screen is shown at a typical phone width
- **THEN** the grid lays the cards out in two columns

#### Scenario: More columns when wider
- **WHEN** the screen is shown at a tablet width
- **THEN** the grid shows more than two columns and the cards keep roughly the width they have on a phone

#### Scenario: No overflow when narrow
- **WHEN** the screen is shown at the smallest supported phone width
- **THEN** no card overflows its cell and no layout error is reported

#### Scenario: Product without an image
- **WHEN** a product has no image, or its image cannot be loaded
- **THEN** its card shows a neutral placeholder in the image area and the rest of the card is unaffected

### Requirement: Searching
Submitting the search field, by its action button or by the keyboard, SHALL request the products matching the entered text and replace the results with them. A submission of blank text SHALL be ignored and SHALL leave the screen as it is. The entered text SHALL survive a submission so the user can refine it.

#### Scenario: Submit a query
- **WHEN** the user types "nike" and submits
- **THEN** the products matching "nike" are requested and shown

#### Scenario: Blank query is ignored
- **WHEN** the user submits an empty or whitespace-only search field
- **THEN** no request is made and the screen does not change

#### Scenario: Query survives the search
- **WHEN** a search completes
- **THEN** the search field still holds the submitted text

### Requirement: Screen states
The results area SHALL show exactly one of five states. Before the first search it SHALL show a prompt to search. While a request is in flight it SHALL show a loading indicator. When the request succeeds with products it SHALL show the grid. When it succeeds with no products it SHALL show a no-results message naming the query. When it fails it SHALL show an error message and a retry control that repeats the same request with the same query, sort and price filter.

#### Scenario: Before the first search
- **WHEN** the app is launched and nothing has been searched
- **THEN** the results area shows a prompt to search, no grid, and no request has been made

#### Scenario: Loading
- **WHEN** a request is in flight
- **THEN** the results area shows a loading indicator instead of the previous content

#### Scenario: No results
- **WHEN** a search for "zzzqqq" returns no products
- **THEN** the results area shows a no-results message mentioning "zzzqqq"

#### Scenario: Failure and retry
- **WHEN** a search fails and the user activates the retry control
- **THEN** an error message was shown first, and the retry repeats the search with the same query, sort and price filter

### Requirement: Sorting
The sort control SHALL open the design system's sort bottom sheet offering, in order, relevance, price ascending and price descending, with the current choice preselected. Each option SHALL be the pair of a sort type and a direction, and every ordering offered SHALL be one the catalog service performs across the whole result set, so that it stays correct as further pages are appended. An ordering the service cannot perform SHALL NOT be offered. Choosing an option SHALL apply it to the current query and reload the results from the first page. Dismissing the sheet without choosing SHALL leave the sort unchanged.

Relevance SHALL be the default and SHALL be offered as an option like any other, so that a user who has chosen an ordering can return to it. Every ordering the screen can reach SHALL be reachable again after leaving it: no choice may be one-way.

#### Scenario: Options and order
- **WHEN** the user opens the sort sheet
- **THEN** it offers relevance, price ascending and price descending, in that order, and no ordering by product name

#### Scenario: Current choice is preselected
- **WHEN** the user opened the sort sheet after having chosen price descending
- **THEN** price descending is shown as selected

#### Scenario: The default is shown as chosen
- **WHEN** the user opens the sort sheet before having chosen any ordering
- **THEN** relevance is shown as selected, because it is the ordering in effect

#### Scenario: Returning to the default ordering
- **WHEN** the user has chosen price ascending and then chooses relevance
- **THEN** the results are requested again in the service's default order, and no ordering the screen offers is a one-way choice

#### Scenario: Choosing a sort reloads from the first page
- **WHEN** the user chooses price ascending after having scrolled through several pages
- **THEN** the results are requested again from the first page for the current query, sorted by ascending price, and the previously accumulated products are discarded

#### Scenario: Ordering holds across pages
- **WHEN** the user sorts by ascending price and scrolls far enough to append another page
- **THEN** the prices continue to ascend across the join between the two pages

#### Scenario: Dismissing keeps the sort
- **WHEN** the user closes the sort sheet without choosing
- **THEN** the sort is unchanged and no request is made

### Requirement: Filtering by price
The filters control SHALL open the design system's filters bottom sheet with a minimum and a maximum price field, prefilled with the filter currently applied. Applying SHALL refresh the results with the entered bounds; either bound MAY be left empty, and an empty bound SHALL NOT constrain that end. Clearing SHALL empty both fields, and applying afterwards SHALL remove the price filter. A minimum greater than the maximum SHALL be reported in the sheet and SHALL NOT be applied. Dismissing the sheet without applying SHALL leave the filter unchanged.

#### Scenario: Apply a range
- **WHEN** the user enters 100 and 200 and applies
- **THEN** the results are requested again for the current query, restricted to prices between 100 and 200

#### Scenario: Only one bound
- **WHEN** the user enters a minimum of 100, leaves the maximum empty and applies
- **THEN** the results are restricted to prices of at least 100 and are not restricted above

#### Scenario: Prefilled with the applied filter
- **WHEN** the user reopens the filters sheet after applying 100 to 200
- **THEN** the fields show 100 and 200

#### Scenario: Clearing removes the filter
- **WHEN** the user clears both fields and applies
- **THEN** the results are requested again without any price restriction

#### Scenario: Inverted range is rejected
- **WHEN** the user enters a minimum of 200 and a maximum of 100 and applies
- **THEN** the sheet reports the problem, stays open, and no request is made

#### Scenario: Dismissing keeps the filter
- **WHEN** the user closes the filters sheet without applying
- **THEN** the filter is unchanged and no request is made

### Requirement: Search, sort and filter combine
The query, the sort and the price filter SHALL be independent settings that all apply to the results at the same time. Changing one SHALL keep the other two and SHALL restart the results from the first page.

#### Scenario: A new search keeps sort and filter
- **WHEN** the user has price descending and a 100 to 200 filter applied, and searches for "adidas"
- **THEN** the results are for "adidas", still sorted by descending price and still restricted to 100 to 200

#### Scenario: Changing a setting restarts the pages
- **WHEN** the user has appended several pages and then changes the query, the sort or the price filter
- **THEN** the accumulated products are discarded and the results start again from the first page

### Requirement: Results continue as the user scrolls
The results area SHALL append the next page of products as the user approaches the end of the grid, without losing the scroll position and without requesting the same page twice while a request is in flight. A product already shown SHALL NOT be shown a second time. Appending SHALL stop when the catalog has no further products to give, and the screen SHALL NOT report the end of the list as an error or as an empty result. A failure while appending SHALL leave the products already on screen untouched and SHALL offer a retry that asks for the same page again.

#### Scenario: Appending the next page
- **WHEN** the user scrolls near the end of the grid
- **THEN** the next page is requested and its products are appended below the existing ones, keeping the scroll position

#### Scenario: One request at a time
- **WHEN** further scrolling happens while a page request is in flight
- **THEN** no second request is made for the same page

#### Scenario: No duplicates
- **WHEN** an appended page contains products that are already shown
- **THEN** only the products not yet shown are appended, and none appears twice in the grid

#### Scenario: End of the catalog
- **WHEN** an appended page contains no product that is not already shown
- **THEN** appending stops, nothing is added, the grid keeps the products it has, and no error or empty state is shown

#### Scenario: No further requests after the end
- **WHEN** the user keeps scrolling after the end of the catalog has been reached
- **THEN** no further page is requested

#### Scenario: Failure while appending
- **WHEN** a page request fails while appending
- **THEN** the products already shown remain visible, a retry is offered below them, and activating it requests the same page again

#### Scenario: A first-page failure is different
- **WHEN** the first page of a search fails
- **THEN** the whole results area shows the error state, not a footer retry

### Requirement: Results of a superseded request are discarded
The catalog screen SHALL show only the results of the latest search, sort or price filter the user applied. When a request completes after a newer search, sort or filter has been started, its outcome, whether products or failure, SHALL be dropped without changing what the screen shows. A further page that completes after the results were restarted SHALL likewise be dropped.

#### Scenario: Slow search finishes after a newer one
- **WHEN** the user searches "a", then searches "b", and the request for "b" completes before the one for "a"
- **THEN** the screen shows the results of "b" and the late results of "a" are ignored

#### Scenario: Slow search fails after a newer one succeeded
- **WHEN** a superseded search fails after a newer search has succeeded
- **THEN** the screen keeps showing the newer results and no failure is shown

#### Scenario: Sort changed while a further page is loading
- **WHEN** the user changes the sort while a further page of the previous ordering is still loading
- **THEN** the late page is not added to the results of the new ordering

#### Scenario: Latest request still applies normally
- **WHEN** no newer request has been started
- **THEN** the outcome of the request is shown as usual
