# ExpressTemplates Changelog

## Version 0.6.0

* Switched out the Expander and related classes to use arbre gem instead
* This is mostly backward compatible but introduces some breaking changes:
  - dom ids must be specified with an id: key instead of as first parameter
  - some capabilities have been removed as they are no longer necessary
  - must use normal ruby control-flow in template fragements instead of for_each, unless_block, etc.
  - wrapping must be accomplished using methods and blocks instead of wrap_with
  - css class names must be specified as class: parameters instead of using .class_name methods

