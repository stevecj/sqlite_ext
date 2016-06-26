require 'spec_helper'

# Functionality added to SQLite3::Database when the sqlite_ext
# gem is loaded.

describe SQLite3::Database do
  subject{ described_class.new(TEST_DB_FILE) }

  after do
    subject.close unless subject.closed?
  end

  context "when a specific function HAS NOT been created" do
    it "indicates that the function HAS NOT been created" do
      expect( subject.function_created?( :foo  ) ).to eq( false )
      expect( subject.function_created?( :FOO  ) ).to eq( false )
      expect( subject.function_created?( 'foo' ) ).to eq( false )
      expect( subject.function_created?( 'FOO' ) ).to eq( false )
    end
  end

  context "when a specific function HAS been created" do
    before do
      subject.create_function('foo', 0){ |fn|  }
    end

    it "indicates that the function HAS been created" do
      expect( subject.function_created?( :foo  ) ).to eq( true )
      expect( subject.function_created?( :FOO  ) ).to eq( true )
      expect( subject.function_created?( 'foo' ) ).to eq( true )
      expect( subject.function_created?( 'FOO' ) ).to eq( true )
    end
  end

end
