# frozen_string_literal: true

require "json"
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
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end
end
