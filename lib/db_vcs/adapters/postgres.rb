# frozen_string_literal: true

module DbVcs
  module Adapters
    class Postgres
      class Config
        attr_accessor :host, :port, :username, :password

        def initialize
          @host = "localhost"
          @port = "5432"
          @username = "postgres"
          @password = nil
        end
      end

      class << self
        # @return [DbVcs::Adapters::Postgres::Config]
        def config
          DbVcs.config.pg_config
        end

        # @return [PG::Connection]
        def connection
          @connection ||=
            begin
              require "pg"
              PG.connect(user: config.username, host: config.host, port: config.port, password: config.password)
            end
        end

        # @param db_name [String]
        # @return [Boolean]
        def db_exists?(db_name)
          !connection.exec("SELECT 1 AS one FROM pg_database WHERE datname='#{db_name}' LIMIT 1").first.nil?
        end

        # @param to_db [String]
        # @param from_db [String]
        # @return void
        def copy_database(to_db, from_db)
          connection.exec("CREATE DATABASE #{to_db} TEMPLATE #{from_db} OWNER #{config.username}")
        end

        # @return [Array<String>]
        def list_databases
          connection.exec("SELECT datname FROM pg_database WHERE datistemplate = false").to_a.flat_map(&:values)
        end

        # @param db_name [String]
        # @return [void]
        def drop_by_dbname(db_name)
          connection.exec("DROP DATABASE IF EXISTS #{db_name}")
        end
      end
    end
  end
end
