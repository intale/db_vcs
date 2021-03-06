# frozen_string_literal: true

class DbHelper
  class << self
    # @param env [String]
    # @param branch_name [String]
    # @return [void]
    def pre_create_pg(env, branch_name)
      return if DbVcs::Manager.get_adapter_by_name("postgres").db_exists?(DbVcs::Utils.db_name(env, branch_name))

      DbVcs::Manager.get_adapter_by_name("postgres").create_database(DbVcs::Utils.db_name(env, branch_name))
    end

    # @param env [String]
    # @param branch_name [String]
    # @return [void]
    def pre_create_mongo(env, branch_name)
      return if DbVcs::Manager.get_adapter_by_name("mongo").db_exists?(DbVcs::Utils.db_name(env, branch_name))

      DbVcs::Manager.get_adapter_by_name("mongo").create_database(DbVcs::Utils.db_name(env, branch_name))
    end

    # @param env [String]
    # @param branch_name [String]
    # @return [void]
    def pre_create_mysql(env, branch_name)
      return if DbVcs::Manager.get_adapter_by_name("mysql").db_exists?(DbVcs::Utils.db_name(env, branch_name))

      DbVcs::Manager.get_adapter_by_name("mysql").create_database(DbVcs::Utils.db_name(env, branch_name))
    end

    # @param adapter_name [String]
    # @param env [String]
    # @param branch_name [String]
    # @return [void]
    def pre_create_by_adapter_name(adapter_name, env, branch_name)
      case adapter_name
      when "mongo"
        pre_create_mongo(env, branch_name)
      when "postgres"
        pre_create_pg(env, branch_name)
      when "mysql"
        pre_create_mysql(env, branch_name)
      else
        raise NotImplementedError, "Don't know how to handle `#{adapter_name}'."
      end
    end

    # @param env [String]
    # @param branch_name [String]
    def pre_create_all(env, branch_name)
      pre_create_pg(env, branch_name)
      pre_create_mongo(env, branch_name)
      pre_create_mysql(env, branch_name)
    end

    # @param env [String]
    # @param branch_name [String]
    def drop_all(env, branch_name)
      DbVcs::Manager::ADAPTERS.keys.each do |adapter_name|
        DbVcs::Manager.get_adapter_by_name(adapter_name).drop_by_dbname(DbVcs::Utils.db_name(env, branch_name))
      end
    end
  end
end
