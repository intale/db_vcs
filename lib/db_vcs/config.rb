# frozen_string_literal: true

module DbVcs
  class Config
    # Environments you want to create database versions for. Default is ["development", "test"]
    attr_accessor :environments
    # This name will be used as a prefix to all copies of master database. Defaults to the name of current folder.
    attr_accessor :db_basename
    # A list of databases you want to enable versioning for. See {DbVcs::Manager::ADAPTERS} keys for the list of
    # available values. Defaults to empty array.
    attr_accessor :dbs_in_use
    # Configuration of dbs clients
    attr_reader :pg_config, :mongo_config

    def initialize
      @environments = %w(development test)
      @dbs_in_use = []
      @db_basename = Dir.pwd.split(File::SEPARATOR).last
      @pg_config = DbVcs::Adapters::Postgres::Config.new
      @mongo_config = DbVcs::Adapters::Mongo::Config.new
    end
  end
end
