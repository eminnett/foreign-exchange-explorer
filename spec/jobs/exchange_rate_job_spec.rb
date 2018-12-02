# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExchangeRateJob, type: :job do
  after(:context) do
    Sidekiq::Worker.clear_all
  end

  context "when no source is provided" do
    it "uses ECB by default" do
      expect_any_instance_of(Importers::EuropeanCentralBank)
        .to receive(:import_exchange_rates)
      ExchangeRateJob.new.perform
    end
  end

  context "when an unhandled source is provided" do
    it "raises an exception" do
      expect {
        ExchangeRateJob.new.perform(source: :FOO)
      }.to raise_error(
        "The ExchangeRateJob does not know how to handle source FOO."
      )
    end
  end
end
