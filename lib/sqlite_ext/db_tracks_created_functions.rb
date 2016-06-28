require 'set'

module SqliteExt

  module DbTracksCreatedFunctions

    # Adds recording of names of created functions to
    # `create_function`.
    if RUBY_VERSION.split('.').first.to_i >= 2

      def create_function(name, arity, *other_args, &block)
        super
        created_function_names << name_key_from(name)
      end

    else

      def self.included(other)
        orig_create_function = other.instance_method(:create_function)
        other.send :define_method, :create_function, proc{ |name, arity, *other_args, &block|
          orig_create_function.bind(self).call name, arity, *other_args, &block
          created_function_names << name_key_from(name)
        }
      end

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
