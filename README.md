[![Build Status](https://travis-ci.com/Ivanov-Anton/active_admin_search.svg?branch=master)](https://travis-ci.com/Ivanov-Anton/active_admin_search) [![Coverage Status](https://coveralls.io/repos/github/Ivanov-Anton/active_admin_search/badge.svg?branch=create_modules_with_conresponding_functional)](https://coveralls.io/github/Ivanov-Anton/active_admin_search?branch=create_modules_with_conresponding_functional)
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_admin_search'
```

And then execute:

$ bundle install

## Usage

##### You can override the default search method named "term"

```ruby
ActiveAdmin.register Author do
active_admin_search! json_term_key: :custom_search_key
end
```

model definition
```ruby
class Author
scope :custom_search_key, ->(term) { where('name = ?', term) }
end
```

###### And more that you can force rename term key that is having name `term`

example:
```ruby
ActiveAdmin.register Author do
active_admin_search! term_key_rename: :custom_term, highlight: :custom_term
end
```
```
localhost:3000/authors/search?term=text
```
model definition
```ruby
class Author
scope :custom_term, ->(term) { where('name = ?', term) }
end
```
###### using this setting, regardless of which variable is used in the ajax request, the custom_term method will be called anyway

## Pagination
##### You can disable default limit defined in your specific database
```ruby
active_admin_search! skip_pagination: true
```

If you want to define a specific limit you can use ``limit`` key defined after ```skip_pagination```
or define as in example below
```ruby
active_admin_search! limit: 1000
```

### Default fields in response

By default, active_admin_search gem response your records with two key ``[{ "value":"1", "text":"Ukraine"" }]``
value we get from record id, and text we get from special models method named: display_name,
but you can override these behaviors using key `display_method`.
You can also override the value itself using the `value_method` setting.

Example:
```ruby
active_admin_search! display_method: :display_record
``` 
### You can define additional fields as in example below
supported value: Hash, Array of Hashes, Lambda
```ruby
active_admin_search! additional_payload: [:deleted_at, :other_method]
active_admin_search! additional_payload: :deleted_at
active_admin_search! additional_payload: ->(record) {{
deleted_date: record.deleted_at,
custom_field_name: record.display_name
}}
```

## Scope
#### If you want to use scope as default, something like `not_deleted` please use `default_scope` key
example:
```ruby
active_admin_search! default_scope: :not_deleted
```
```ruby
active_admin_search! default_scope: [:not_deleted, :tagged]
```

then you can override it if needed using url params: `skip_default_scopes`
example:
```
localhost:3000/posts/search?term=text&skip_default_scopes=true
```
more that you can define scope or list of scopes from url using scope variable
example
```
localhost:3000/authors/search?term=string&scope=taged,not_deleted
```

## Search with prefix id:

You can perform a search record by id even if your scope is searching by a different field.

###### Default behavior
```
localhost:3000/authors/search?term=string
```
then
```sql
SELECT "authors".* FROM "authors" WHERE "authors"."name" LIKE '%string%'
```
###### Search using prefix id:
```
localhost:3000/authors/search?term=id:443
```
then
```sql
SELECT "authors".* FROM "authors" WHERE "authors"."id" = 443
```
This works because we specify a prefix named id: at the beginning of the search term

##### Highlight search response
You can highlight your response to easy perform search

example below to enable this feature
```ruby
active_admin_search! highlight: :term
```

##### N+1 problem

To solve N+1 problem you can use a special setting named **includes**
example for Article:
```ruby
active_admin_search! includes: [:category, :tag]
```

#### Order
If you want override default order (id: :desc) you can use setting order_clause like examples below:

```ruby
active_admin_search! order_clause: :deleted_at
```
then
```sql
SELECT "authors".* FROM "authors" ORDER BY "authors"."deleted_at" ASC
```
----------------------------
```ruby
active_admin_search! order_clause: { deleted_at: :desc }
```
then
```sql
SELECT "authors".* FROM "authors" ORDER BY "authors"."deleted_at" DESC
```

### If you want to search within foreign key see example below
```ruby
active_admin_search!
```
```
localhost:3000/article/search?term=text&q[author_id_eq]=1
```
then
```sql
SELECT "articles".* FROM "articles" WHERE "articles"."author_id" = 1
```
