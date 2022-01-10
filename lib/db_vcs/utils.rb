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
        "#{DbVcs.config.db_basename}_#{environment}_#{normalized_branch_name(branch)}"
      end

      # Removes special characters from branch name
      # @param branch [String] a name of a branch
      # @return [String]
      def normalized_branch_name(branch)
        branch.gsub(/[\W]/, '_')
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
