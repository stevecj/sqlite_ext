module SqliteExt
  module InitInjection
    def initialize(file, *other_init_args)
      if block_given?
        super file, *other_init_args do |db|
          SqliteExt.enhance_db_session self
          yield db
        end
      else
        db = super
        SqliteExt.enhance_db_session db
      end
    end
  end
end
