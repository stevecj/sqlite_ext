require 'spec_helper'

describe SqliteExt do
  attr_accessor :db

  before do
    subject.purge_function_registrations
  end

  after do
    db.close if db && (! db.closed?)
  end

  it "has a version number" do
    expect(SqliteExt::VERSION).not_to be nil
  end

  it "allows registering a function to be auto-created using SQLite3#create_function protocol" do
    subject.register_create_function "sqrt", 1 do |fn,x|
      fn.result = Math.sqrt(x)
    end

    actual = nil
    SQLite3::Database.new(TEST_DB_FILE) do |db|
      actual = db.execute("SELECT sqrt(25)")
    end

    self.db = SQLite3::Database.new(TEST_DB_FILE)
    actual = db.execute("SELECT sqrt(25)")
    expect( actual ).to eq( [[5.0]] )
  end

  it "provides a collection of registered function names" do
    subject.register_create_function 'foo', 1 do |fn,x| ; end
    subject.register_create_function 'bar', 1 do |fn,x| ; end
    expect( subject.registered_function_names ).
      to contain_exactly( 'foo', 'bar' )
  end

  describe "registration of Ruby math" do
    before do
      subject.register_ruby_math
    end

    it "registers singleton methods from Ruby's `Math` module as functions" do
      actual = nil
      SQLite3::Database.new(TEST_DB_FILE) do |db|
        actual = db.execute(<<-EOS).first
          SELECT
            cbrt(125),
            log(1000, 10)
        EOS
      end

      expect( actual[0] ).to be_within( 0.00001 ).of( 5.0 )
      expect( actual[1] ).to be_within( 0.00001 ).of( 3.0 )
    end

    it "registers `floor` and `ceil` functions" do
      actual = nil
      SQLite3::Database.new(TEST_DB_FILE) do |db|
        actual = db.execute(<<-EOS).first
          SELECT
            floor( 1.9 ),
            floor(-1.9 ),
            ceil( 1.1 ),
            ceil(-1.1 )
        EOS
      end

      expect( actual ).to eq([
         1.0,
        -2.0,
         2.0,
        -1.0
      ])
    end
  end

  describe "registration of a function for a block that returns a value" do
    before do
      subject.register_function("format", ->(template, v1, *vv){
        vv.map!{ |v| v || -1 }
        template % [v1, *vv]
      })
      self.db = SQLite3::Database.new(TEST_DB_FILE)
    end

    it "uses the specified function to process non-NULL values" do
      actual = db.execute(
        "SELECT format('result: %d %d', 8, 9)"
      )[0][0]

      expect( actual ).to eq('result: 8 9')
    end

    it "propagates NULLs for any required arguments" do
      actual = db.execute( <<-EOS )[0]
        SELECT
            format( NULL,             NULL )
          , format( 'result: %d, %d', NULL )
          , format( NULL,             5    )
      EOS

      expect( actual ).to eq( [nil, nil, nil] )
    end

    it "processes NULLs for any optional arguments" do
      actual = db.execute( <<-EOS )[0]
        SELECT
          format('result: %d %d', 8, NULL),
          format('result: %d %d %d', 8, NULL, NULL)
      EOS

      expect( actual ).to eq([
        'result: 8 -1',
        'result: 8 -1 -1'
      ])
    end
  end

end
