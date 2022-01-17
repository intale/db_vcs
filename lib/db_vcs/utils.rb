# frozen_string_literal: true

module DbVcs
  module Utils
    class << self
      # @return [String] current branch name
      def current_branch
        `git rev-parse --abbrev-ref HEAD`.chomp
      end

      # @return [Array<String>] array of local branches names
      def git_branches
        `git for-each-ref refs/heads --format='%(refname:short)'`.scan(/[[:graph:]]+/)
      end

      # Generate db name, based on branch name and environment.
      # @param environment [String] application's environment name. E.g. "development", "test"
      # @param branch [String]
      # @return [String]
      def db_name(environment, branch)
        [DbVcs.config.db_basename, environment, branch].map do |str|
          normalize_db_part(str)
        end.join("_")
      end

      # Removes special characters from string that is used as a part of database name
      # @param str [String]
      # @return [String]
      def normalize_db_part(str)
        str.gsub(/[\W]/, "_")
      end

      # @param exec [String] a name of executable
      # @param fallback_exec [String] a name of executable to fallback to if exec was not resolved
      # @return [String] path to executable
      def resolve_exec_path(exec, fallback_exec: nil)
        path = `which #{exec}`.chomp
        return resolve_exec_path(fallback_exec) if fallback_exec && path.empty?

        path.empty? ? exec : path
      end
    end
  end
end
