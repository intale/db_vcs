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
    end

    attr_reader :adapter, :adapter_name

    # @param adapter_name [String]
    def initialize(adapter_name)
      @adapter_name = adapter_name
      @adapter = self.class.get_adapter_by_name(adapter_name)
    end

    # @param :branch [String] target branch name
    # @param :source_branch [String] a branch name to copy the db from
    # @return [void]
    def copy_for_all_envs(branch:, source_branch: "master")
      DbVcs.config.environments.each do |environment|
        copy_for_env(branch: branch, source_branch: source_branch, env: environment)
      end
    end

    # @param :branch [String] target branch name
    # @param :source_branch [String] a branch name to copy the db from
    # @param :env [String]
    # @return [void]
    def copy_for_env(branch:, source_branch:, env:)
      copy_for(Utils.db_name(env, branch), Utils.db_name(env, source_branch))
    end

    # @param db_name [String]
    # @return [void]
    def drop(db_name)
      adapter.drop_by_dbname(db_name)
      success "database #{db_name} was dropped successfully"
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

    private

    # @param to_db [String]
    # @param from_db [String]
    # @return [void]
    def copy_for(to_db, from_db)
      unless adapter.db_exists?(from_db)
        return failure "#{from_db}' doesn't exist"
      end
      if adapter.db_exists?(to_db)
        return failure "#{to_db} already exists"
      end
      success "Copying #{from_db} -> #{to_db}"
      adapter.copy_database(to_db, from_db)
    end
  end
end
