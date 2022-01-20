# frozen_string_literal: true

module DbVcs
  module Adapters
    class Mongo
      class Config
        include DbVcs::ConfigAttributes

        # Path to mongodump util. It is resolved automatically.
        attr_accessor :mongodump_path
        # Path to mongorestore util. It is resolved automatically.
        attr_accessor :mongorestore_path
        # Mongodb connection uri. Defaults to "mongodb://localhost:27017".
        # See https://docs.mongodb.com/manual/reference/connection-string/ for more info.
        attr_accessor :mongo_uri

        def initialize
          @mongodump_path = Utils.resolve_exec_path("mongodump")
          @mongorestore_path = Utils.resolve_exec_path("mongorestore")
          @mongo_uri = "mongodb://localhost:27017"
        end
      end

      class << self
        include DbVcs::AdapterInterface

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

        # @param db_name [String]
        # @return void
        def create_database(db_name)
          # Mongodb databases should contain at least one collection
          connection.use(db_name).database.collection("_db_vcs").insert_one(_db_vcs: 1)
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
