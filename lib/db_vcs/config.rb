# frozen_string_literal: true

module DbVcs
  class Config
    # Environments you want to create database versions for. Default is ["development", "test"]
    attr_accessor :environments
    # This name will be used as a prefix to all copies of master database. Defaults to the name of current folder.
    attr_accessor :db_basename
    # Configuration of dbs clients
    attr_accessor :pg_config, :mongo_config

    def initialize
      @environments = %w(development test)
      @db_basename = Dir.pwd.split(File::SEPARATOR).last
      @pg_config = DbVcs::Adapters::Postgres::Config.new
      @mongo_config = DbVcs::Adapters::Mongo::Config.new
    end
  end
end
