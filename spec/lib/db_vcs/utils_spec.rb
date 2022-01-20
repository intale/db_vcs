# frozen_string_literal: true

RSpec.describe DbVcs::Utils do
  describe ".current_branch" do
    subject { described_class.current_branch }

    it "returns current git branch" do
      is_expected.to be_a(String)
    end
  end

  describe ".git_branches" do
    subject { described_class.git_branches }

    it "returns a list of local branches" do
      is_expected.to include(DbVcs.config.main_branch)
    end
  end

  describe ".db_name" do
    subject { described_class.db_name(env, branch) }

    let(:env) { "some-env" }
    let(:branch) { "some-br" }
    let(:db_basename) { "some base name" }

    before do
      allow(DbVcs.config).to receive(:db_basename).and_return(db_basename)
    end

    it "returns normalized database name" do
      is_expected.to eq("some_base_name_some_env_some_br")
    end
  end

  describe ".normalize_db_part" do
    subject { described_class.normalize_db_part(str) }

    let(:str) { "some.str- " }

    it "replaces non-word characters with '_'" do
      is_expected.to eq("some_str__")
    end
  end

  describe ".resolve_exec_path" do
    describe "when fallback is not provided" do
      subject { described_class.resolve_exec_path(exec) }

      let(:exec) { "ls" }

      describe "when executable is found" do
        it "returns full path to it" do
          is_expected.to end_with("/#{exec}")
        end
      end

      describe "when executable is not found" do
        let(:exec) { "non-existing-executable" }

        it { is_expected.to eq(exec) }
      end
    end

    describe "when fallback is provided" do
      subject { described_class.resolve_exec_path(exec, fallback_exec: fallback_exec) }

      let(:exec) { "ls" }
      let(:fallback_exec) { "grep" }

      describe "when executable is found" do
        it "returns full path to it" do
          is_expected.to end_with("/#{exec}")
        end
      end

      describe "when executable is not found" do
        let(:exec) { "non-existing-executable" }

        it "returns full path to fallback executable" do
          is_expected.to end_with("/#{fallback_exec}")
        end
      end
    end
  end
end
