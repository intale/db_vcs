# frozen_string_literal: true

RSpec.describe DbVcs::Config do
  let(:instance) { described_class.new }

  describe "#environments" do
    subject { instance.environments }

    it "has default value" do
      is_expected.to eq(%w(development test))
    end
  end

  describe "#environments=" do
    subject { instance.environments = envs_list }

    let(:envs_list) { %(1 2 3) }

    it { expect { subject }.to change { instance.environments }.to(envs_list) }
  end

  describe "#dbs_in_use" do
    subject { instance.dbs_in_use }

    it "has default value" do
      is_expected.to eq([])
    end
  end

  describe "#dbs_in_use=" do
    subject { instance.dbs_in_use = dbs_in_use }

    let(:dbs_in_use) { ["mongo", "postgres"] }

    it { expect { subject }.to change { instance.dbs_in_use }.to(dbs_in_use) }
  end

  describe "#db_basename" do
    subject { instance.db_basename }

    it "has default value" do
      is_expected.to eq(Dir.pwd.split(File::SEPARATOR).last)
    end
  end

  describe "#db_basename=" do
    subject { instance.db_basename = another_name }

    let(:another_name) { "some-name" }

    it { expect { subject }.to change { instance.db_basename }.to(another_name) }
  end

  describe "#main_branch" do
    subject { instance.main_branch }

    it "has default value" do
      is_expected.to eq("main")
    end
  end

  describe "#main_branch=" do
    subject { instance.main_branch = main_branch }

    let(:main_branch) { "some-branch" }

    it { expect { subject }.to change { instance.main_branch }.to(main_branch) }
  end

  describe "#pg_config" do
    subject { instance.pg_config }

    it { is_expected.to be_a(DbVcs::Adapters::Postgres::Config) }
  end

  describe "#pg_config=" do
    subject { instance.pg_config = pg_config }

    let(:pg_config) { { username: "somepguser" } }

    before do
      instance.pg_config.port = "0"
    end

    it "changes pg config values, provided in hash" do
      expect { subject }.to change { instance.pg_config.username }.to(pg_config[:username])
    end
    it "does not change pg config values, not existing in hash" do
      expect { subject }.not_to change { instance.pg_config.port }
    end
  end

  describe "#mongo_config" do
    subject { instance.mongo_config }

    it { is_expected.to be_a(DbVcs::Adapters::Mongo::Config) }
  end

  describe "#mongo_config=" do
    subject { instance.mongo_config = mongo_config }

    let(:mongo_config) { { mongo_uri: "mongodb://some/uri" } }

    before do
      instance.mongo_config.mongodump_path = "/path/to/mongodump"
    end

    it "changes mongo config values, provided in hash" do
      expect { subject }.to change { instance.mongo_config.mongo_uri }.to(mongo_config[:mongo_uri])
    end
    it "does not change mongo config values, not existing in hash" do
      expect { subject }.not_to change { instance.mongo_config.mongodump_path }
    end
  end

  describe "#mysql_config" do
    subject { instance.mysql_config }

    it { is_expected.to be_a(DbVcs::Adapters::Mysql::Config) }
  end

  describe "#mysql_config=" do
    subject { instance.mysql_config = mysql_config }

    let(:mysql_config) { { mysql_path: "/path/to/mysql" } }

    before do
      instance.mysql_config.mysqldump_path = "/path/to/mysqldump"
    end

    it "changes mysql config values, provided in hash" do
      expect { subject }.to change { instance.mysql_config.mysql_path }.to(mysql_config[:mysql_path])
    end
    it "does not change mysql config values, not existing in hash" do
      expect { subject }.not_to change { instance.mysql_config.mysqldump_path }
    end
  end

  describe "#assign_attributes" do
    subject { instance.assign_attributes(attrs) }

    let(:attrs) { { db_basename: "some-db-name", "main_branch" => "some-branch", not_existing_attr: "some-value" } }

    it "assigns config attribute, represented as symbol" do
      expect { subject }.to change { instance.db_basename }.to(attrs[:db_basename])
    end
    it "assigns config attribute, represented as string" do
      expect { subject }.to change { instance.main_branch }.to(attrs["main_branch"])
    end
    it "ignores non-existing attribute" do
      expect { subject }.not_to raise_error
    end
  end
end