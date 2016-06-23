# SqliteExt

Note that the work on this gem is still in the early stages, so
the text below represents what it is intended to do. The gem does
not yet accomplish all of that as of yet.

Provides a convenient way of writing functions in Ruby that can
be called from with in SQLite queries through the SQLite3 gem.

Although it is already possible to write ruby code for functions
that can be called from within SQL queries using SQLite via the
SQLite3 gem, that has some limitations which this gem seeks to
address.

First, when utilizing `SQLite3::Database#create_function`, the
added function only exists for the current instance of
`SQLite3::Database`. If that instance is being accessed through
a connection pool (e.g. via ActiveRecord) then there it is hard
to ensure that the functions are created on each new instance
before the SQL that needs them to exist is executed.

Secondly, the Ruby code needed to define a trivial SQL-callable
function using `SQLite3::Database#create_function` is fairly
verbose, and it would be nice to have a simpler API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sqlite_ext'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqlite_ext

## Usage

    SqliteExt.register_create_function 'sqrt', 1 do |fn,x|
      fn.result =
        case x
        when nil then nil
        else Math.sqrt(x)
        end
    end

    SQLite3::Database.new 'data.db' do |db|
      puts db.execute("SELECT sqrt(25)")[0][0]
    end
    # Output: 5.0

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sqlite_ext. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

