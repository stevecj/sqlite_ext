### 1.5.0 - 2016-05-26
* Enhancements
  * Now works with Ruby versions prior to 2.x.

### 1.4.0 - 2016-05-26
* Enhancements
  * `SqliteExt.register_ruby_math` now also registers `pi`, `e`, `mod`,
    and `power` functions.

### 1.3.0 - 2016-05-26
* Features
  * Adds `SQLite3::Database.function_created?` to check whether a
    function with a given name has been created on the target instance.

### 1.2.0 - 2016-05-25
* Enhancements
  * `SqliteExt.register_ruby_math` no longer re-registers functions when
    they should already/still be registered.
* Features
  * `SqliteExt.register_ruby_math!` has been added to unconditionally
    register or re-register Ruby math functions.

### 1.1.0 - 2016-05-25
* Enhancements
  * `SqliteExt.register_ruby_math` now also registers `floor` and `ceil`
    functions.

### 1.0.0 - 2016-06-23
* Features
  * Added `SqliteExt.register_ruby_math`. Registers most of Ruby's `Math`
    module methods as SQLite SQL functions.

### 0.3.0 - 2016-06-23
* Removals
  * Removed support for a block argument to `SqliteExt.register_function`.
    It now accepts a `Proc` passed as a standard argument instead.
* Enhancements
  * Functions registered using `SqliteExt.register_function` automatically
    propagate `NULL` when `NULL` is passed for one or more of the required
    parameters of the `Proc` that performs the function.
