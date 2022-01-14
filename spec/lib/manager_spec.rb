# frozen_string_literal: true

RSpec.describe DbVcs::Manager do
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

    before do
      DbVcs.config.environments.each do |env|
        DbHelper.pre_create_all(env, source_branch)
      end
    end

    DbVcs.config.environments.each do |env|
      DbVcs::Manager::ADAPTERS.keys.each do |adapter_name|
        describe "when using '#{adapter_name}' database" do
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

  describe "instance" do
    subject { described_class.new(adapter_name) }

    let(:adapter_name) { "postgres" }

    its(:adapter) { is_expected.to eq(DbVcs::Adapters::Postgres) }
    its(:adapter_name) { is_expected.to eq(adapter_name) }
  end
end
