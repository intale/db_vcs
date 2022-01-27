# frozen_string_literal: true

RSpec.describe DbVcs::Adapters::Mongo do
  describe "Config" do
    let(:instance) { described_class::Config.new }

    describe "#mongodump_path" do
      subject { instance.mongodump_path }

      it "has default value" do
        is_expected.to eq(DbVcs::Utils.resolve_exec_path("mongodump"))
      end
    end

    describe "#mongodump_path=" do
      subject { instance.mongodump_path = mongodump_path }

      let(:mongodump_path) { "/some/path" }

      it { expect { subject }.to change { instance.mongodump_path }.to(mongodump_path) }
    end

    describe "#mongorestore_path" do
      subject { instance.mongorestore_path }

      it "has default value" do
        is_expected.to eq(DbVcs::Utils.resolve_exec_path("mongorestore"))
      end
    end

    describe "#mongorestore_path=" do
      subject { instance.mongorestore_path = mongorestore_path }

      let(:mongorestore_path) { "/some/path" }

      it { expect { subject }.to change { instance.mongorestore_path }.to(mongorestore_path) }
    end

    describe "#mongo_uri" do
      subject { instance.mongo_uri }

      it "has default value" do
        is_expected.to eq("mongodb://localhost:27017")
      end
    end

    describe "#mongo_uri=" do
      subject { instance.mongo_uri = mongo_uri }

      let(:mongo_uri) { "mongodb://some/uri" }

      it { expect { subject }.to change { instance.mongo_uri }.to(mongo_uri) }
    end

    describe "#assign_attributes" do
      subject { instance.assign_attributes(attrs) }

      let(:attrs) do
        {
          mongodump_path: "/path/to/mongodump",
          "mongorestore_path" => "/path/to/mongorestore",
          not_existing_attr: "some-value"
        }
      end

      it "assigns config attribute, represented as symbol" do
        expect { subject }.to change { instance.mongodump_path }.to(attrs[:mongodump_path])
      end
      it "assigns config attribute, represented as string" do
        expect { subject }.to change { instance.mongorestore_path }.to(attrs["mongorestore_path"])
      end
      it "ignores non-existing attribute" do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe ".config" do
    subject { described_class.config }

    it { is_expected.to eq(DbVcs.config.mongo_config) }
  end

  describe ".connection" do
    subject { described_class.connection }

    it { is_expected.to be_a(Mongo::Client) }
  end

  describe ".db_exists?" do
    subject { described_class.db_exists?(db_name) }

    let(:db_name) { DbVcs::Utils.db_name("test", branch_name) }
    let(:branch_name) { "some-branch" }

    describe "when db exists" do
      before do
        DbHelper.pre_create_mongo("test", branch_name)
      end

      it { is_expected.to be_truthy }
    end

    describe "when db does not exist" do
      it { is_expected.to eq(false) }
    end
  end

  describe ".copy_database" do
    subject { described_class.copy_database(to_db, from_db) }

    let(:to_db) { DbVcs::Utils.db_name("test", target_branch) }
    let(:from_db) { DbVcs::Utils.db_name("test", source_branch) }
    let(:target_branch) { "some-target-branch" }
    let(:source_branch) { "some-existing-branch" }

    before do
      DbHelper.pre_create_mongo("test", source_branch)
    end

    it "creates new db" do
      expect { subject }.to change { described_class.db_exists?(to_db) }.to(true)
    end
  end

  describe ".list_databases" do
    subject { described_class.list_databases }

    let(:existing_db_name) { DbVcs::Utils.db_name("test", branch_name) }
    let(:branch_name) { "some-branch" }

    before do
      DbHelper.pre_create_mongo("test", branch_name)
    end

    it "returns array of existing mongodb databases" do
      is_expected.to include(existing_db_name)
    end
    it { is_expected.to be_an(Array) }
  end

  describe ".create_database" do
    subject { described_class.create_database(db_name) }

    let(:db_name) { DbVcs::Utils.db_name("test", "some-branch-name") }

    it "creates new database" do
      expect { subject }.to change { described_class.db_exists?(db_name) }.to(true)
    end
  end

  describe ".drop_by_dbname" do
    subject { described_class.drop_by_dbname(existing_db_name) }

    let(:existing_db_name) { DbVcs::Utils.db_name("test", branch_name) }
    let(:branch_name) { "some-existing-db" }

    before do
      DbHelper.pre_create_mongo("test", branch_name)
    end

    it "deletes db by name" do
      expect { subject }.to change { described_class.db_exists?(existing_db_name) }.to(false)
    end
  end
end
