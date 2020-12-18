# frozen_string_literal: true

require_relative 'lib/active_admin_search/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_admin_search'
  spec.version       = ActiveAdminSearch::VERSION
  spec.authors       = ['Anton Ivanov']
  spec.email         = ['anton.i@didww.com']

  spec.summary       = 'Flexible ActiveAdmin search support by term'
  spec.description   = 'Flexible ActiveAdmin search support by term'
  spec.homepage      = 'https://github.com/activeadmin-plugins'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.5')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir['{lib}'].reject { |f| File.directory?(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activeadmin'
end
