# frozen_string_literal: true

module DbVcs
  module Adapters
    class Mysql
      class Config
        include DbVcs::ConfigAttributes

        attr_accessor :host, :port, :username, :password
        # Path to mysqldump util. It is resolved automatically.
        attr_accessor :mysqldump_path
        # Path to mysql util. It is resolved automatically.
        attr_accessor :mysql_path

        def initialize
          @host = "127.0.0.1"
          @port = "3306"
          @username = "root"
          @password = nil
          @mysqldump_path = DbVcs::Utils.resolve_exec_path("mysqldump")
          @mysql_path = DbVcs::Utils.resolve_exec_path("mysql")
        end
      end

      class << self
        include DbVcs::AdapterInterface

        # @return [DbVcs::Adapters::Mysql::Config]
        def config
          DbVcs.config.mysql_config
        end

        # @return [Mysql2::Client]
        def connection
          @connection ||=
            begin
              require "mysql2"
              Mysql2::Client.new(
                host: config.host,
                username: config.username,
                port: config.port,
                password: config.password
              )
            end
        end

        # @param db_name [String]
        # @return [Boolean]
        def db_exists?(db_name)
          !connection
             .query("SELECT 1 as one FROM `INFORMATION_SCHEMA`.`SCHEMATA` WHERE `SCHEMA_NAME` = '#{db_name}' LIMIT 1")
             .first.nil?
        end

        # @param to_db [String]
        # @param from_db [String]
        # @return void
        def copy_database(to_db, from_db)
          create_opts =
            connection.query(<<~SQL).first
              SELECT `DEFAULT_CHARACTER_SET_NAME` as charset, `DEFAULT_COLLATION_NAME` as collation
              FROM `INFORMATION_SCHEMA`.`SCHEMATA` WHERE `SCHEMA_NAME` = '#{from_db}' LIMIT 1
            SQL
          connection.query(<<~SQL)
            CREATE DATABASE #{to_db} CHARACTER SET #{create_opts["charset"]} COLLATE #{create_opts["collation"]}
          SQL
          password_opt = config.password.to_s.strip.empty? ? "" : "-p#{config.password}"
          command =
            <<~SH
            #{config.mysqldump_path} -u #{config.username} #{password_opt} -h #{config.host} -P #{config.port} #{from_db} \
            | #{config.mysql_path} -u #{config.username} #{password_opt} -h #{config.host} -P #{config.port} #{to_db}
          SH
          `#{command}`
        end

        # @param db_name [String]
        # @return void
        def create_database(db_name)
          connection.query("CREATE DATABASE #{db_name}")
        end

        # @return [Array<String>]
        def list_databases
          connection.query("SELECT `SCHEMA_NAME` FROM `INFORMATION_SCHEMA`.`SCHEMATA`").to_a.flat_map(&:values)
        end

        # @param db_name [String]
        # @return [void]
        def drop_by_dbname(db_name)
          connection.query("DROP DATABASE #{db_name}")
        end
      end
    end
  end
end
