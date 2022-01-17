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

  describe "#pg_config" do
    subject { instance.pg_config }

    it { is_expected.to be_a(DbVcs::Adapters::Postgres::Config) }
  end

  describe "#mongo_config" do
    subject { instance.mongo_config }

    it { is_expected.to be_a(DbVcs::Adapters::Mongo::Config) }
  end
end