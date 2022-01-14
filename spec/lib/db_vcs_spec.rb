# frozen_string_literal: true

RSpec.describe DbVcs do
  describe ".config" do
    subject { described_class.config }

    it { is_expected.to be_a(described_class::Config) }
  end

  describe ".configure" do
    it { expect { |blk| described_class.configure(&blk) }.to yield_with_args(instance_of(described_class::Config)) }
  end
end
