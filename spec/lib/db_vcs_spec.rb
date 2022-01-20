# frozen_string_literal: true

RSpec.describe DbVcs do
  describe ".config" do
    subject { described_class.config }

    it { is_expected.to be_a(described_class::Config) }
  end

  describe ".configure" do
    it { expect { |blk| described_class.configure(&blk) }.to yield_with_args(instance_of(described_class::Config)) }
  end

  describe ".load_config", fakefs: true do
    subject { described_class.load_config }

    let(:yaml_hash) { { db_basename: "some-name", main_branch: "<%= 'some-branch' %>" } }
    let(:config) { described_class::Config.new }

    before do
      allow(described_class).to receive(:config).and_return(config)
    end

    after do
      allow(described_class).to receive(:config).and_call_original
    end

    describe "when config file exists" do
      before do
        f = File.new(".db_vcs.yml", "w")
        f.write(yaml_hash.to_yaml)
        f.close
      end

      it "loads values from it" do
        expect { subject }.to change { config.db_basename }.to(yaml_hash[:db_basename])
      end
      it "supports erb template" do
        expect { subject }.to change { config.main_branch }.to("some-branch")
      end
    end

    describe "when config file does not exist" do
      it "does not load anything" do
        expect { subject }.not_to change { config.db_basename }
      end
    end
  end
end
