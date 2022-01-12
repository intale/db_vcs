# frozen_string_literal: true

require_relative "lib/db_vcs/version"

Gem::Specification.new do |spec|
  spec.name          = "db_vcs"
  spec.version       = DbVcs::VERSION
  spec.authors       = ["Ivan Dzyzenko"]
  spec.email         = ["ivan.dzyzenko@gmail.com"]

  spec.summary       = "Database versions control."
  spec.description   = "Have a separate database for each git branch!"
  spec.homepage      = "https://github.com/intale/db_vcs"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.4.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/intale/vcs_db/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "https://github.com/intale/vcs_db/blob/v#{spec.version}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "pg", "~> 1.2"
  spec.add_development_dependency "mongo", "~> 2.17"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rspec-its", "~> 1.3"
  spec.add_development_dependency "fivemat", "~> 1.3"
  spec.add_development_dependency "dotenv", "~> 2.7"
  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "term-ansicolor", "~> 1.7", ">= 1.7.1"
  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
