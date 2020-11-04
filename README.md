# ActiveAdminSearch

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/active_admin_search`. To experiment with that code, run `bin/console` for an interactive prompt.
requirements:
bundler: 1.17.3 version
TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_admin_search'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install active_admin_search

## Usage

##### You can override default search method named "term"

```ruby
active_admin_search! json_term_key: :custom_search_key
```

## Pagination
##### You can disable default limit defined in your specific database
```ruby
active_admin_search! skip_pagination: true
```

If you want define specific limit you can use ``limit`` key defined after ```skip_pagination```
or define as in example below
```ruby
active_admin_search! limit: 1000
```

### Default fields in responce

By default active_admin_search gem responce your records with two key ``[{ "value":"1", "text":"Ukraine"" }]``
value we get from record id, and text we get from special models method named: display_name,
but you can override this behaviours using key `display_method`
example:
```ruby
active_admin_search! display_method: :display_record
```  
### You can define additional fields as in example below
```ruby
active_admin_search! additional_fields: [:deleted_at]
```

## Scope
#### If you want use scope as default, something like `not_deleted` please use `default_scope` key
example:
```ruby
active_admin_search! default_scope: :not_deleted
```

then you can override it if needed using url param: `skip_default_scopes`
example:
```
localhost:3000/posts/search?term=text&skip_default_scopes=true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Ivanov-Anton/active_admin_search. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/active_admin_search/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveAdminSearch project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/active_admin_search/blob/master/CODE_OF_CONDUCT.md).
