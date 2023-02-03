# Description

This project documents a concrete implementation of a light-weight version of the FFLIB Trigger Framework, based on the [Apex Enterprise Pattern Github](https://github.com/apex-enterprise-patterns) workspace.

## Components

- `SObjbectDomain`: base `virtual` class that constitutes what logics should be run in the particular trigger events, and more importantly: ensures that those key 'logics' methods are called in the right order and timing(_see the `triggerHandler()` method_).
- `OpportunityTrigger2` & `OpportunityTriggerHandler2` is a demonstration-only purpose example implementation of such a framework, illustrating how an actual implementation could look like:
  - Highlights: the application of the `onApplyDefaults()` and `onValidate()` methods illustrates some core advantages of such a framework that provides ease in extensibility and maintenance.

### Notes

    The classes `OpportunityTrigger2`, `OpportunityTriggerHandler2`, and so on, are for illustrative purposes only.

    Furthermore, the `OpportunityTriggerHandler2Test` class was introduced just as a starting point for properly configured & healthy unit tests.
## Installation

TBD

## License

The MIT License (MIT).