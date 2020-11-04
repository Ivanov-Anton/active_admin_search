##### ArgumentError Exception: wrong number of arguments
If tou pass value 1 through term then ransack expect number 1 as boolean

###### Solution1 1
To avoid the mistake you can define special setting in initialize rails
```ruby
Ransack.configure do |config|
  # Accept my custom scope values as what they are
  config.sanitize_custom_scope_booleans = false
end
```

*** ArgumentError Exception: wrong number of arguments (given 0, expected 1)
scope :term, -> (value) do