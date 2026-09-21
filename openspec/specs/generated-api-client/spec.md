# generated-api-client Specification

## Purpose

Governs the generated backend client package: how it comes into being, what a developer may safely change inside it, and how the rest of the app is allowed to depend on it, so that regenerating it is never a risk and never a prerequisite for building.

## Requirements

### Requirement: The client is generated, not written
The backend client SHALL live in its own package produced from the OpenAPI document by a code generator, and its generated sources SHALL NOT be edited by hand. Regenerating from an unchanged document SHALL leave the working tree unchanged. A change to the contract SHALL be made in the document and regenerated, never patched in the output.

#### Scenario: Regeneration is a no-op when nothing changed
- **WHEN** the client is regenerated from an unchanged document
- **THEN** no tracked file differs

#### Scenario: A contract change flows from the document
- **WHEN** a parameter is added to the document and the client is regenerated
- **THEN** the generated client exposes that parameter without any hand edit

### Requirement: Building and testing never require the generator
The generated package SHALL be committed to the repository, so that building the app, running its tests and running continuous integration require only the Dart and Flutter toolchain. The generator and its runtime SHALL be needed only when regenerating.

#### Scenario: A clean checkout builds without the generator runtime
- **WHEN** the repository is checked out on a machine without the generator's runtime installed, and the app is built and tested
- **THEN** both succeed

#### Scenario: Regeneration states its requirement
- **WHEN** a developer looks for how to regenerate the client
- **THEN** the documented procedure names the runtime it needs

### Requirement: Hand-maintained files inside the package survive regeneration
The generated package SHALL take part in the repository's workspace resolution, which requires a package manifest the generator does not produce. Files that are hand-maintained SHALL be listed so the generator leaves them alone, and regeneration SHALL NOT revert them.

#### Scenario: The manifest survives
- **WHEN** the client is regenerated
- **THEN** the package manifest still declares workspace resolution and the package still resolves as a workspace member

#### Scenario: One dependency resolution
- **WHEN** dependencies are fetched once at the repository root
- **THEN** the generated package's dependencies are resolved together with the other packages

### Requirement: The app depends on the client only through the data layer
Only the data layer SHALL import the generated package. The domain and the presentation layers SHALL NOT reference a generated type, and the generated types SHALL be translated into domain entities before leaving the data layer, so that regenerating the client cannot reach the rest of the app.

#### Scenario: Generated types stop at the data layer
- **WHEN** the imports of the domain and presentation layers are inspected
- **THEN** none of them imports the generated package

#### Scenario: Translation to domain entities
- **WHEN** the data layer returns a search result
- **THEN** it returns domain entities, not generated types

#### Scenario: A renamed generated type touches one place
- **WHEN** a field is renamed in the document and the client is regenerated
- **THEN** only the data layer's translation needs adjusting

### Requirement: The client shares the application's configured transport
The generated client SHALL be constructed with the HTTP client the application already configures, rather than creating its own, so that the address, the timeouts and any future shared behaviour apply to it. Transport errors raised by the generated client SHALL be translated into the application's typed failures before leaving the data layer.

#### Scenario: One transport instance
- **WHEN** the dependency graph is resolved
- **THEN** the generated client uses the same configured HTTP client instance as the rest of the application

#### Scenario: Timeouts apply
- **WHEN** a request through the generated client exceeds the configured timeout
- **THEN** the data layer reports a network failure

#### Scenario: No transport type escapes
- **WHEN** the generated client raises a transport error
- **THEN** the caller of the data layer receives a typed failure and no generator or transport exception propagates
