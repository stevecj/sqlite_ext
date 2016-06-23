gem "sqlite3"
require "sqlite3"

module SqliteExt

  require "sqlite_ext/version"
  require "sqlite_ext/init_injection"

end

class SQLite3::Database
  prepend SqliteExt::InitInjection
end

module SqliteExt

  class << self

    # Registers a block of ruby code to be used as a function in
    # SQL executed through subsequent new instances of
    # `SQLite3::Database`.
    #
    # Example:
    #
    # SqliteExt.register_function('sqrt'){ |x| Math.sqrt(x) }
    #
    # SQLite3::Database.new 'data.db' do |db|
    #   puts db.execute("SELECT sqrt(25)")[0][0]
    # end
    # # Output: 5.0
    #
    def register_function(name, &block)
      register_create_function name, block.arity do |fn,*args|
        fn.result = block.call(*args)
      end
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
    end

    # Creates all of the registered functions on an instance of
    # `SQLite3::Database`.
    #
    # This is normally called automatically for each new
    # instance, but can also be used to add the functions to
    # an instance that was created before the functions were
    # registered.
    def enhance_db_session(db)
      registered_function_creations.each_value do |(args,block)|
        db.create_function *args, &block
      end
    end

    private

    def registered_function_creations
      @registered_function_creations ||= {}
    end
  end
end
