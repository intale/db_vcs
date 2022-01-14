# frozen_string_literal: true

ENV["APP_ENV"] ||= "test"

require "rspec/its"
require "db_vcs"
require "dotenv/load"

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require(f) }

DbVcs.configure do |c|
  c.dbs_in_use = DbVcs::Manager::ADAPTERS.keys
  c.pg_config.username = ENV["PGUSER"]
  c.pg_config.port = ENV["PG_PORT"]
  c.mongo_config.mongo_uri = "mongodb://localhost:#{ENV["MONGO_PORT"]}"
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.order = :random
  config.seed = Kernel.srand % 0xFFFF

  config.after do
    DbVcs::Manager::ADAPTERS.keys.each do |adapter_name|
      adapter = DbVcs::Manager.get_adapter_by_name(adapter_name)
      adapter.list_databases.select { |db_name| db_name.include?(DbVcs.config.db_basename) }.each do |db_name|
        adapter.drop_by_dbname(db_name)
      end
    end
  end
end
