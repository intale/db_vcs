# frozen_string_literal: true

require "json"
require "yaml"
require "erb"
require_relative "db_vcs/config_attributes"
require_relative "db_vcs/config"
require_relative "db_vcs/adapter_interface"
require_relative "db_vcs/adapters/mongo"
require_relative "db_vcs/adapters/postgres"
require_relative "db_vcs/utils"
require_relative "db_vcs/manager"
require_relative "db_vcs/version"

module DbVcs
  class Error < StandardError; end

  class << self
    # @return [DbVcs::Config]
    def config
      @config ||= DbVcs::Config.new
    end

    def configure
      yield config
    end

    def load_config
      config_path = File.join(Dir.pwd, ".db_vcs.yml")
      if File.exists?(config_path)
        config.assign_attributes(YAML.load(ERB.new(File.read(config_path)).result))
      end
    end
  end
end
