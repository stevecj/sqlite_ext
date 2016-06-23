spec_path = File.dirname(__FILE__)
root = File.dirname(spec_path)
lib_path = File.join(root, 'lib')
tmp_db_path = File.join(root, 'tmp', 'db')

$LOAD_PATH.unshift lib_path
require 'sqlite_ext'

require 'fileutils'
FileUtils.mkdir_p tmp_db_path

TEST_DB_FILE = File.join(tmp_db_path, 'test.db')
