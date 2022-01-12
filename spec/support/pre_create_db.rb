# frozen_string_literal: true

class PreCreateDb
  class << self
    # @return [void]
    def pre_create_pg
      return if DbVcs::Manager.new("postgres").adapter.db_exists?(DbVcs.config.db_basename)

      DbVcs::Manager.new("postgres").adapter.connection.exec("CREATE DATABASE #{DbVcs.config.db_basename}")
    end

    # @return [void]
    def pre_create_mongo
      return if DbVcs::Manager.new("mongo").adapter.db_exists?(DbVcs.config.db_basename)

      DbVcs::Manager.new("mongo")
                    .adapter.connection.use(DbVcs.config.db_basename).database.collection("test").insert_one(test: 1)
    end
  end
end
