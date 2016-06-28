require 'set'

module SqliteExt

  module DbAutoCreatesRegisteredFunctions

    # Adds functions registered with SqliteExt to each new
    # instance before it is returned from `.new` or `.open` or is
    # passed to the given block.
    if RUBY_VERSION.split('.').first.to_i >= 2

      def initialize(file, *other_init_args)
        if block_given?
          super file, *other_init_args do
            SqliteExt.enhance_db_session self
            yield self
          end
        else
          super
          SqliteExt.enhance_db_session self
        end
      end

    else

      def self.included(other)
        orig_initialize = other.instance_method(:initialize)

        other.send :define_method, :initialize, proc{ |file, *other_init_args, &block|
          if block
            orig_initialize.bind(self).call file, *other_init_args do
              SqliteExt.enhance_db_session self
              block.call self
            end
          else
            orig_initialize.bind(self).call file, *other_init_args
            SqliteExt.enhance_db_session self
          end
        }
      end

    end

  end

end
