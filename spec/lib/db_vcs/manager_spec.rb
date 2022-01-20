# frozen_string_literal: true

RSpec.describe DbVcs::Manager do
  let(:instance) { described_class.new(adapter_name) }
  let(:adapter_name) { "postgres" }

  shared_examples "copies database" do
    describe "when source database does not exist" do
      before do
        instance.adapter.drop_by_dbname(source_db)
      end

      it "does not create target database" do
        expect { subject }.not_to change { instance.adapter.db_exists?(target_db) }
      end
      it "outputs failure" do
        expect { subject }.to output(a_string_including("#{source_db}' doesn't exist")).to_stdout
      end
    end

    describe "when target database already exists" do
      before do
        instance.adapter.copy_database(target_db, source_db)
      end

      it "outputs failure" do
        expect { subject }.to output(a_string_including("#{target_db} already exists")).to_stdout
      end
    end

    describe "when all is ok" do
      before do
        allow(instance).to receive(:success).and_call_original
      end

      it "creates target database" do
        expect { subject }.to change { instance.adapter.db_exists?(target_db) }.to(true)
      end
      it "outputs success" do
        expect { subject }.to output(a_string_including("Copying #{source_db} -> #{target_db}")).to_stdout
      end
    end
  end

  shared_examples "drops database" do
    describe "when database exists" do
      it "drops it" do
        expect { subject }.to change { instance.adapter.db_exists?(db_name) }.to(false)
      end
      it "outputs success" do
        expect { subject }.to output(a_string_including("Database #{db_name} was dropped successfully")).to_stdout
      end
    end

    describe "when database does not exist" do
      before do
        instance.adapter.drop_by_dbname(db_name)
      end

      it "outputs failure" do
        expect { subject }.to output(a_string_including("#{db_name}' doesn't exist")).to_stdout
      end
    end
  end

  describe "constants" do
    describe "ADAPTERS" do
      subject { described_class::ADAPTERS }

      it do
        is_expected.to(
          eq(
            "postgres" => DbVcs::Adapters::Postgres, "mongo" => DbVcs::Adapters::Mongo
          )
        )
      end
      it { is_expected.to be_frozen }

      describe "adapters classes" do
        subject { super().values }

        it { is_expected.to all be_a(DbVcs::AdapterInterface) }
      end
    end
  end

  describe ".get_adapter_by_name" do
    subject { described_class.get_adapter_by_name(adapter_name) }

    let(:adapter_name) { "postgres" }

    describe "when adapter exists" do
      it "returns it" do
        is_expected.to eq(DbVcs::Adapters::Postgres)
      end
    end

    describe "when adapter does not exist" do
      let(:adapter_name) { "some-db" }

      it "raises error" do
        expect { subject }.to raise_error(NotImplementedError, "No adapter for `#{adapter_name}' is implemented.")
      end
    end
  end

  describe ".copy_for_all_envs" do
    subject { described_class.copy_for_all_envs(target: target_branch, source: source_branch) }

    let(:target_branch) { "some-new-br" }
    let(:source_branch) { "some-source-br" }

    DbVcs.config.environments.each do |env|
      DbVcs::Manager::ADAPTERS.keys.each do |adapter_name|
        describe "when using '#{adapter_name}' database" do
          before do
            DbHelper.pre_create_all(env, source_branch)
          end

          describe "withing '#{env}' environment" do
            it_behaves_like "copies database" do
              let(:instance) { described_class.new(adapter_name) }
              let(:target_db) { DbVcs::Utils.db_name(env, target_branch) }
              let(:source_db) { DbVcs::Utils.db_name(env, source_branch) }
            end
          end
        end
      end
    end
  end

  describe ".drop_for_all_envs" do
    subject { described_class.drop_for_all_envs(branch_name) }

    let(:branch_name) { "some-branch" }

    DbVcs.config.environments.each do |env|
      DbVcs::Manager::ADAPTERS.keys.each do |adapter_name|
        describe "when using '#{adapter_name}' database" do
          before do
            DbHelper.pre_create_all(env, branch_name)
          end

          describe "withing '#{env}' environment" do
            it_behaves_like "drops database" do
              let(:instance) { described_class.new(adapter_name) }
              let(:db_name) { DbVcs::Utils.db_name(env, branch_name) }
            end
          end
        end
      end
    end
  end

  describe "instance" do
    subject { described_class.new(adapter_name) }

    let(:adapter_name) { "postgres" }

    its(:adapter) { is_expected.to eq(DbVcs::Adapters::Postgres) }
    its(:adapter_name) { is_expected.to eq(adapter_name) }
  end

  describe "#copy" do
    subject { instance.copy(target: target_db, source: source_db) }

    let(:source_branch) { "some-source-br" }
    let(:target_db) { DbVcs::Utils.db_name("test", "some_target_br") }
    let(:source_db) { DbVcs::Utils.db_name("test", source_branch) }

    before do
      DbHelper.pre_create_pg("test", source_branch)
    end

    it_behaves_like "copies database"
  end

  describe "#drop" do
    subject { instance.drop(db_name) }

    let(:db_name) { DbVcs::Utils.db_name("test", br_name) }
    let(:br_name) { "some-branch" }

    before do
      DbHelper.pre_create_pg("test", br_name)
    end

    it_behaves_like "drops database"
  end

  describe "#message" do
    subject { instance.message(text) }

    let(:text) { "some text" }

    it { is_expected.to eq("#{adapter_name.capitalize} :: #{text}") }
  end

  describe "#success" do
    subject { instance.success(text) }

    let(:text) { "some text" }

    it { expect { subject }.to output("\e[1m\e[32m#{instance.message(text)}\e[0m\e[0m\n").to_stdout }
  end

  describe "#failure" do
    subject { instance.failure(text) }

    let(:text) { "some text" }

    it { expect { subject }.to output("\e[1m\e[31m#{instance.message(text)}\e[0m\e[0m\n").to_stdout }
  end

  describe "#regular" do
    subject { instance.regular(text) }

    let(:text) { "some text" }

    it { expect { subject }.to output("#{instance.message(text)}\n").to_stdout }
  end
end
