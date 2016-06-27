gem "sqlite3"
require "sqlite3"

module SqliteExt
  require "sqlite_ext/version"
  require "sqlite_ext/db_tracks_created_functions"
  require "sqlite_ext/db_auto_creates_registered_functions"
end

class SQLite3::Database
  prepend SqliteExt::DbTracksCreatedFunctions
  prepend SqliteExt::DbAutoCreatesRegisteredFunctions
end

module SqliteExt

  class << self

    # Registers a Ruby `Proc` to be used as a function in SQL
    # code executed through subsequent new instances of
    # `SQLite3::Database`.
    #
    # When `NULL` value is passed 1 or more of the `Proc`'s
    # required parameters, it will be "propagated", meaning that
    # the specified `Proc` will not be invoked and `NULL` will be
    # returned from the call in SQL.
    #
    # When non-`NULL` values are passed to all of the `Proc`'s
    # required parameters and `NULL` is passed to any or all of
    # the `Proc`'s optional parameters, they will NOT be
    # propagated, and the `Proc` WILL be invoked. Values passed
    # as `NULL` in SQL will be forwarded to the `Proc` as Ruby
    # `nil`s.
    #
    # Whenever the `Proc` is called and returns `nil`, that will
    # result in `NULL` being returned from the function call in
    # SQL.
    #
    # Example:
    #
    # SqliteExt.register_function(
    #   'sqrt',
    #   ->(x){ Math.sqrt(x) }
    # )
    #
    # SQLite3::Database.new 'data.db' do |db|
    #   puts db.execute(
    #     "SELECT sqrt(25), COALESCE(sqrt(NULL), -1)"
    #   ).first
    # end
    #
    # # == Output ==
    # # 5.0
    # # -1
    #
    def register_function(name, prok)
      minimum_arity =
        prok.
        parameters.select{ |(kind,_)| kind == :req }.
        count

      register_create_function name, minimum_arity do |fn,*args|
        fn.result =
          if args[0...minimum_arity].any?{ |a| a.nil? }
            nil
          else
            prok.call(*args)
          end
      end
    end

    # Registers most of the public module methods of Ruby's
    # `Math` module as well as `ceil`, `floor`, `mod`, and
    # `power` based on `Float` instance methods to be used as
    # functions in SQL code executed through subsequent new
    # instances of `SQLite3::Database`.
    #
    # The `Math.frexp` method is omitted becuse it returns an
    # array, and there is no way to return an array from a SQL
    # function in SQLite.
    #
    # `NULL`s are propagated as described in the documentation
    # for `register_function`.
    #
    # Note that calling `register_ruby_math` more than once
    # without calling `purge_function_registrations` in between
    # has no effect. Ruby math functions remain registered and
    # are not re-registered in that case.
    def register_ruby_math
      return if ruby_math_is_registered
      register_ruby_math!
    end

    # Registers or re-registers Ruby math. You may want to call
    # this method if one or more of the functions defined by a
    # previous call to `register_ruby_math` or
    # `register_ruby_math!` may have been subsequently replaced.
    #
    # See `register_ruby_math`.
    def register_ruby_math!
      fn_methods = Math.public_methods - (Module.instance_methods << :frexp)
      fn_methods.each do |m|
        register_function m, Math.method(m)
      end
      register_function 'pi', ->(){ Math::PI }
      register_function 'e',  ->(){ Math::E }
      [
        [ :floor ],
        [ :ceil  ],
        [ :modulo, :mod   ],
        [ :**,     :power ]
      ].each do |(*args)|
        m, fn = args.first, args.last
        register_function fn, m.to_proc
      end
      self.ruby_math_is_registered = true
    end

    # Registers a #create_function call to be invoked on every
    # new instance of `SQLite3::Database` immidately after it is
    # instantiated and before it is returned from the call to
    # `.new` and before the invocation of a block that is passed
    # to `.new`.
    #
    # The parameters passed to `#register_create_function` are
    # exactly the same as those that would be passed to
    # `SQLite3::Database#create_function`.
    #
    # Note that this only affects instances of
    # `SQLite3::Database` that are subsequently created and has
    # no effect on previously created instances.
    #
    # Example:
    #
    # SqliteExt.register_create_function 'sqrt', 1 do |fn,x|
    #    fn.result =
    #      case x
    #        when nil then nil
    #        else Math.sqrt(x)
    #        end
    #      end
    #
    # SQLite3::Database.new 'data.db' do |db|
    #   puts db.execute("SELECT sqrt(25)")[0][0]
    # end
    # # Output: 5.0
    #
    def register_create_function(name, arity, *other_args, &block)
      name = "#{name}"
      registered_function_creations[name] = [
        [name, arity, *other_args],
        block
      ]
    end

    # Returns an array of the names of all currently registered
    # functions.
    def registered_function_names
      registered_function_creations.keys
    end

    # Removes all function registrations. Has no effect on
    # existing instances of `SQLite3::Database`.
    def purge_function_registrations
      registered_function_creations.clear
      self.ruby_math_is_registered = false
    end

    # Creates all of the registered functions on an instance of
    # `SQLite3::Database`.
    #
    # This is normally called automatically for each new
    # instance, but it can also be used to add the functions to
    # an instance that was created before the functions were
    # registered.
    def enhance_db_session(db)
      registered_function_creations.each_value do |(args,block)|
        db.create_function *args, &block
      end
    end

    private

    attr_accessor :ruby_math_is_registered

    def registered_function_creations
      @registered_function_creations ||= {}
    end

  end
end
