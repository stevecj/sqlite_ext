require 'set'

module SqliteExt

  module DbAutoCreatesRegisteredFunctions

    # Adds functions registered with SqliteExt to each new
    # instance before it is returned from `.new` or `.open`or is
    # passed to the given block.
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

  end

end
