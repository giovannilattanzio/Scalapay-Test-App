/// Defaults of a search, not properties of the endpoint: kept in a neutral
/// file that anything in the `catalog` feature can depend on, since both an
/// entity (`ProductPageAccumulator`) and a use case (`ProductSearchParams`)
/// need them and neither should import the other's directory.
const kDefaultPage = 1;
const kDefaultPerPage = 30;
const kDefaultLanguageCode = 'it';
