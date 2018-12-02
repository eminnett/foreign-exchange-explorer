# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rate do
  let(:rate_data) do
    {
      base_currency:    "GBP",
      counter_currency: "USD",
      date:             Date.parse("2018-11-26"),
      value:            1.284826
    }
  end
  let(:rate) { Rate.new(rate_data) }

  describe "validations" do
    it { should validate_presence_of(:id) }
    it { should validate_presence_of(:base_currency) }
    it { should validate_presence_of(:counter_currency) }
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:value) }
  end

  describe "#attributes" do
    it "returns a hash of the instance attributes" do
      attributes = rate.attributes
      core_attributes = attributes.select {|k, _v| rate_data.key?(k) }
      expect(attributes.keys).to eq(Rate::ATTRIBUTES.reject {|a| a == :_id })
      expect(core_attributes).to eq(rate_data)
    end
  end

  describe "#to_s" do
    it "is formatted correctly" do
      expect(rate.to_s).to eq(
        "1 GBP equalled 1.284826 USD on 2018-11-26."
      )
    end
  end
end
