# frozen_string_literal: true

module DbVcs
  module Adapters
    class Mongo
      class Config
        attr_accessor :mongodump_path, :mongorestore_path, :mongo_uri

        def initialize
          @mongodump_path = Utils.resolve_exec_path("mongodump")
          @mongorestore_path = Utils.resolve_exec_path("mongorestore")
          @mongo_uri = "mongodb://localhost:27017"
        end
      end

      class << self
        # @return [DbVcs::Adapters::Mongo::Config]
        def config
          DbVcs.config.mongo_config
        end

        # @return [Mongo::Client]
        def connection
          @connection ||=
            begin
              require "mongo"
              ::Mongo::Client.new(config.mongo_uri)
            end
        end

        # @param db_name [String]
        # @return [Boolean]
        def db_exists?(db_name)
          list_databases.include?(db_name)
        end

        # @param to_db [String]
        # @param from_db [String]
        # @return void
        def copy_database(to_db, from_db)
          command =
            <<~SH
            #{config.mongodump_path} #{config.mongo_uri} --db="#{from_db}" --archive --quiet \
            | #{config.mongorestore_path} #{config.mongo_uri} --archive --quiet --nsFrom='#{from_db}.*' --nsTo='#{to_db}.*'
          SH
          `#{command}`
        end

        # @return [Array<String>]
        def list_databases
          connection.database_names
        end

        # @param db_name [String]
        # @return [void]
        def drop_by_dbname(db_name)
          connection.use(db_name).database.drop
        end
      end
    end
  end
end
