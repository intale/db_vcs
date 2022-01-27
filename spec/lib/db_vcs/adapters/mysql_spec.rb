# frozen_string_literal: true

RSpec.describe DbVcs::Adapters::Mysql do
  describe "Config" do
    let(:instance) { described_class::Config.new }

    describe "#host" do
      subject { instance.host }

      it "has default value" do
        is_expected.to eq("127.0.0.1")
      end
    end

    describe "#host=" do
      subject { instance.host = host }

      let(:host) { "some.host" }

      it { expect { subject }.to change { instance.host }.to(host) }
    end

    describe "#port" do
      subject { instance.port }

      it "has default value" do
        is_expected.to eq("3306")
      end
    end

    describe "#host=" do
      subject { instance.port = port }

      let(:port) { "3307" }

      it { expect { subject }.to change { instance.port }.to(port) }
    end

    describe "#username" do
      subject { instance.username }

      it "has default value" do
        is_expected.to eq("root")
      end
    end

    describe "#username=" do
      subject { instance.username = username }

      let(:username) { "mysql" }

      it { expect { subject }.to change { instance.username }.to(username) }
    end

    describe "#password" do
      subject { instance.password }

      it "does not have default value" do
        is_expected.to be_nil
      end
    end

    describe "#password=" do
      subject { instance.password = password }

      let(:password) { "some-password" }

      it { expect { subject }.to change { instance.password }.to(password) }
    end

    describe "#mysqldump_path" do
      subject { instance.mysqldump_path }

      it "has default value" do
        is_expected.to eq(DbVcs::Utils.resolve_exec_path("mysqldump"))
      end
    end

    describe "#mysqldump_path=" do
      subject { instance.mysqldump_path = mysqldump_path }

      let(:mysqldump_path) { "/path/to/mysqldump" }

      it { expect { subject }.to change { instance.mysqldump_path }.to(mysqldump_path) }
    end

    describe "#mysql_path" do
      subject { instance.mysql_path }

      it "has default value" do
        is_expected.to eq(DbVcs::Utils.resolve_exec_path("mysql"))
      end
    end

    describe "#mysql_path=" do
      subject { instance.mysql_path = mysql_path }

      let(:mysql_path) { "/path/to/mysql" }

      it { expect { subject }.to change { instance.mysql_path }.to(mysql_path) }
    end
  end

  describe ".config" do
    subject { described_class.config }

    it { is_expected.to eq(DbVcs.config.mysql_config) }
  end

  describe ".connection" do
    subject { described_class.connection }

    it { is_expected.to be_a(Mysql2::Client) }
  end

  describe ".db_exists?" do
    subject { described_class.db_exists?(db_name) }

    let(:db_name) { DbVcs::Utils.db_name("test", branch_name) }
    let(:branch_name) { "some-branch" }

    describe "when db exists" do
      before do
        DbHelper.pre_create_mysql("test", branch_name)
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
      DbHelper.pre_create_mysql("test", source_branch)
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
      DbHelper.pre_create_mysql("test", branch_name)
    end

    it "returns array of existing mysql databases" do
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
      DbHelper.pre_create_mysql("test", branch_name)
    end

    it "deletes db by name" do
      expect { subject }.to change { described_class.db_exists?(existing_db_name) }.to(false)
    end
  end
end
