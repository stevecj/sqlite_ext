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

  it "allows registering a function to be auto-created for a block that simply returns a value" do
    subject.register_function("sqrt"){ |x| Math.sqrt(x) }

    self.db = SQLite3::Database.new(TEST_DB_FILE)
    actual = db.execute("SELECT sqrt(25)")
    expect( actual ).to eq( [[5.0]] )
  end

end
