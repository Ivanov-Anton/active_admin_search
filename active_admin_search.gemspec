# frozen_string_literal: true

require_relative 'lib/active_admin_search/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_admin_search'
  spec.version       = ActiveAdminSearch::VERSION
  spec.authors       = ['Ivanov-Anton']
  spec.email         = ['anton.i@didww.com']

  spec.summary       = 'Gem that provide easy search resource throught ajax'
  spec.description   = 'You can get all your records by executing the following request "your_app.com/users/search"'
  spec.homepage      = 'https://github.com/Ivanov-Anton/active_admin_search'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.5')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activeadmin'
end
