require_relative "lib/authorio/version"

Gem::Specification.new do |spec|
  spec.name        = "authorio-updated"
  spec.version     = Authorio::VERSION
  spec.authors     = [ "Michael Meckler, Libreverse Contributors" ]
  spec.email       = [ "rattroupe@reiterate-app.com", "resists-oysters.0s@icloud.com" ]
  spec.homepage    = "https://blog.reiterate.app/tag/authorio/"
  spec.summary     = "updated version of the Indieauth Authentication endpoint for Rails"
  spec.description = "updated version of the Rails engine to add IndieAuth authentication endpoint functionality"
  spec.license     = "MIT"

  spec.required_ruby_version = '~> 3.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["source_code_uri"] = "https://github.com/reiterate-app/authorio"
  spec.metadata["changelog_uri"] = "https://github.com/reiterate-app/authorio/blob/master/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 8"
  spec.add_dependency "bcrypt", "~> 3.0"
  spec.add_dependency "jbuilder", "~> 2.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 5.0"
  spec.add_development_dependency "byebug", "~> 11.0"
end
