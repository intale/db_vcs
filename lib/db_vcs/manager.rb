# frozen_string_literal: true

module DbVcs
  class Manager
    ADAPTERS = { "postgres" => DbVcs::Adapters::Postgres, "mongo" => DbVcs::Adapters::Mongo }.freeze

    class << self
      # @param adapter_name [String]
      # @return [Class<DbVcs::Adapters::Postgres>, Class<DbVcs::Adapters::Mongo>]
      # @raise [NotImplementedError] in case if no adapter is found
      def get_adapter_by_name(adapter_name)
        ADAPTERS[adapter_name] || raise(NotImplementedError, "No adapter for `#{adapter_name}' is implemented.")
      end

      # Creates databases for target branch from source branch for all setup environments for all setup databases
      # @param :target [String] target branch name
      # @param :source [String] a branch name to copy the db from
      # @return [void]
      def copy_for_all_envs(target:, source: DbVcs.config.main_branch)
        DbVcs.config.dbs_in_use.each do |adapter_name|
          inst = new(adapter_name)
          DbVcs.config.environments.each do |env|
            inst.copy(target: DbVcs::Utils.db_name(env, target), source: DbVcs::Utils.db_name(env, source))
          end
        end
      end

      # Drops databases of given branch name for all environments for all setup databases
      # @param branch_name [String]
      def drop_for_all_envs(branch_name)
        DbVcs.config.dbs_in_use.each do |adapter_name|
          inst = new(adapter_name)
          DbVcs.config.environments.each do |env|
            inst.drop(DbVcs::Utils.db_name(env, branch_name))
          end
        end
      end
    end

    attr_reader :adapter, :adapter_name

    # @param adapter_name [String]
    def initialize(adapter_name)
      @adapter_name = adapter_name
      @adapter = self.class.get_adapter_by_name(adapter_name)
    end

    # @param :target [String] new database name
    # @param :source [String] database name to create a new db from
    # @return [void]
    def copy(target:, source:)
      unless adapter.db_exists?(source)
        return failure "#{source}' doesn't exist"
      end
      if adapter.db_exists?(target)
        return failure "#{target} already exists"
      end
      success "Copying #{source} -> #{target}"
      adapter.copy_database(target, source)
    end

    # @param db_name [String]
    # @return [void]
    def drop(db_name)
      unless adapter.db_exists?(db_name)
        return failure "#{db_name}' doesn't exist"
      end
      adapter.drop_by_dbname(db_name)
      success "Database #{db_name} was dropped successfully"
    end

    # @param db_name [String]
    # @return [void]
    def create(db_name)
      if adapter.db_exists?(db_name)
        return failure "#{db_name}' already exist"
      end
      adapter.create_database(db_name)
      success "Database #{db_name} created successfully"
    end

    # @param text [String, nil]
    # @return void
    def message(text)
      "#{adapter_name.capitalize} :: #{text}"
    end

    # @param text [String, nil]
    # @return void
    def success(text)
      puts "\e[1m\e[32m#{message(text)}\e[0m\e[0m"
    end

    # @param text [String, nil]
    # @return void
    def failure(text)
      puts "\e[1m\e[31m#{message(text)}\e[0m\e[0m"
    end

    # @param text [String, nil]
    # @return void
    def regular(text)
      puts message(text)
    end
  end
end
