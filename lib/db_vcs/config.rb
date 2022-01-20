# frozen_string_literal: true

module DbVcs
  class Config
    include DbVcs::ConfigAttributes

    # Environments you want to create database versions for. Default is ["development", "test"].
    attr_accessor :environments
    # This name will be used as a prefix to all your databases in a project.
    attr_accessor :db_basename
    # A list of databases you want to enable versioning for. See {DbVcs::Manager::ADAPTERS} keys for the list of
    # available values. Defaults to empty array.
    attr_accessor :dbs_in_use
    # Configuration of dbs clients.
    attr_reader :pg_config, :mongo_config
    # A name of branch to be used as a default branch to copy databases from.
    attr_accessor :main_branch

    def initialize
      @environments = %w(development test)
      @dbs_in_use = []
      @db_basename = Dir.pwd.split(File::SEPARATOR).last
      @main_branch = "main"
      @pg_config = DbVcs::Adapters::Postgres::Config.new
      @mongo_config = DbVcs::Adapters::Mongo::Config.new
    end

    # @param hash [Hash]
    # @return [void]
    def pg_config=(hash)
      pg_config.assign_attributes(hash)
    end

    # @param hash [Hash]
    # @return [void]
    def mongo_config=(hash)
      mongo_config.assign_attributes(hash)
    end
  end
end
