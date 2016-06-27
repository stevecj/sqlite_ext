require 'set'

module SqliteExt

  module DbTracksCreatedFunctions

    def create_function(name, arity, *other_args, &block)
      super
      created_function_names << name_key_from(name)
    end

    # Given a name, returns true if a function of that hane has
    # been created on the target instance. The name lookup is
    # case-insensitive, and either a string or a symbol may be
    # supplied.
    def function_created?(name)
      name_key = name_key_from(name)
      created_function_names.include?(name_key)
    end

    private

    def name_key_from(name)
      "#{name}".upcase
    end

    def created_function_names
      @created_function_names ||= Set.new
    end

  end

end
