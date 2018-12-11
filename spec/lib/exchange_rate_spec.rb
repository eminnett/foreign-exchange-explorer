# frozen_string_literal: true

require "rails_helper"
require "rake"
Rails.application.load_tasks

RSpec.describe Rate do
  before(:context) do
    ExchangeRate.set(Date.parse("2018-11-23"), "EUR", "GBP", "0.8848")
    ExchangeRate.set(Date.parse("2018-11-26"), "EUR", "GBP", "0.8844")
    ExchangeRate.set(Date.parse("2018-11-27"), "EUR", "GBP", "0.88748")
    ExchangeRate.set(Date.parse("2018-11-23"), "EUR", "USD", "1.1352")
    ExchangeRate.set(Date.parse("2018-11-26"), "EUR", "USD", "1.1363")
    ExchangeRate.set(Date.parse("2018-11-27"), "EUR", "USD", "1.1328")
    ExchangeRate.set(Date.parse("2018-11-23"), "EUR", "CAD", "1.5019")
    ExchangeRate.set(Date.parse("2018-11-26"), "EUR", "CAD", "1.5011")
    ExchangeRate.set(Date.parse("2018-11-27"), "EUR", "CAD", "1.5018")
    ExchangeRate.repository.refresh_index!
    ExchangeRate.currency_repository.refresh_index!
  end

  after(:context) do
    ExchangeRate.repository.delete_index!
    ExchangeRate.repository.create_index!
    ExchangeRate.currency_repository.delete_index!
    ExchangeRate.currency_repository.create_index!
  end

  describe ".dates" do
    it "should return an array of dates" do
      dates = ExchangeRate.dates
      expect(dates).to be_an(Array)
      dates.each do |date|
        expect { Date.parse(date) }.to_not raise_error
      end
    end
    it "should include the available currency codes" do
      expect(ExchangeRate.dates)
        .to include("2018-11-23", "2018-11-26", "2018-11-27")
    end
  end

  describe ".currencies" do
    it "should return an array of Currencies" do
      currencies = ExchangeRate.currencies
      expect(currencies).to be_an(Array)
      returned_classes = currencies.map(&:class).uniq
      expect(returned_classes.count).to eq(1)
      expect(returned_classes[0]).to eq(Currency)
    end
    it "should include the available currency codes" do
      expect(ExchangeRate.currencies.map(&:code)).to include("EUR", "GBP", "USD", "CAD")
    end
  end

  describe ".set" do
    it "should return a Rate" do
      rate = ExchangeRate.set(Time.zone.today, "AAA", "BBB", 1.2345)
      expect(rate).to be_a(Rate)
    end

    context "when the rate exists in the data store" do
      it "should not duplicate the data in the store" do
        2.times do
          ExchangeRate.set(Time.zone.today, "CCC", "DDD", 1.2345)
          ExchangeRate.repository.refresh_index!
          expect(
            ExchangeRate.repository.exact_match(Time.zone.today, "CCC", "DDD").present?
          ).to be(true)
        end
      end
    end

    context "when the rate does not exist in the data store" do
      it "should populate the rate data in the data store" do
        expect(
          ExchangeRate.repository.exact_match(Time.zone.today, "EEE", "FFF").present?
        ).to be(false)
        ExchangeRate.set(Time.zone.today, "EEE", "FFF", 1.2345)
        ExchangeRate.repository.refresh_index!
        expect(
          ExchangeRate.repository.exact_match(Time.zone.today, "EEE", "FFF").present?
        ).to be(true)
      end
    end
  end

  describe ".find_rate" do
    let(:rate) do
      ExchangeRate.find_rate(Date.parse("2018-11-27"), "EUR", "GBP")
    end

    it "should return a Rate" do
      expect(rate).to be_a(Rate)
    end

    context "when the rate exists in the data store" do
      it "should return the rate" do
        expect(rate.value).to eq("0.88748")
      end
    end

    context "when the rate does not exist in the data store" do
      it "should raise an error" do
        expect {
          ExchangeRate.find_rate(Time.zone.today, "GGG", "HHH")
        }.to raise_error(
          ExchangeRate::NotFound,
          "The exchange rate for GGG in HHH on #{Time.zone.today} is unknown."
        )
      end
    end

    context "when the inverse rate is present in the data store" do
      it "should not raise an error" do
        expect {
          ExchangeRate.find_rate(Date.parse("2018-11-27"), "GBP", "EUR")
        }.to_not raise_error
      end

      it "should calculate the rate from the available inverse" do
        date = Date.parse("2018-11-26")
        existing_rate = ExchangeRate.find_rate(date, "EUR", "GBP")
        calculated_rate = ExchangeRate.find_rate(date, "GBP", "EUR")
        expect(calculated_rate.value.to_f).to eq(1 / existing_rate.value.to_f)
      end

      it "should save the requested rate in the data store" do
        date = Date.parse("2018-11-23")
        search_result_one = ExchangeRate.repository.exact_match(date, "GBP", "EUR")
        expect(search_result_one.present?).to be(false)
        ExchangeRate.find_rate(date, "GBP", "EUR")
        ExchangeRate.repository.refresh_index!
        search_result_two = ExchangeRate.repository.exact_match(date, "GBP", "EUR")
        expect(search_result_two.present?).to be(true)
      end
    end

    context "when two rates exist that could be used to calculate the requested rate" do
      it "should not raise an error" do
        expect {
          ExchangeRate.find_rate(Date.parse("2018-11-27"), "GBP", "USD")
        }.to_not raise_error
      end

      it "should calculate the rate from the two available rates" do
        date = Date.parse("2018-11-26")
        existing_base_rate = ExchangeRate.find_rate(date, "EUR", "GBP")
        existing_counter_rate = ExchangeRate.find_rate(date, "EUR", "USD")
        calculated_rate = ExchangeRate.find_rate(date, "GBP", "USD")
        expect(calculated_rate.value.to_f)
          .to eq(existing_counter_rate.value.to_f / existing_base_rate.value.to_f)
      end

      it "should save the requested rate in the data store" do
        date = Date.parse("2018-11-23")
        search_result_one = ExchangeRate.repository.exact_match(date, "GBP", "USD")
        expect(search_result_one.present?).to be(false)
        ExchangeRate.find_rate(date, "GBP", "USD")
        ExchangeRate.repository.refresh_index!
        search_result_two = ExchangeRate.repository.exact_match(date, "GBP", "USD")
        expect(search_result_two.present?).to be(true)
      end
    end
  end

  describe ".rates_between" do
    let(:rates) do
      ExchangeRate.rates_between(
        Date.parse("2018-11-23"),
        Date.parse("2018-11-27"),
        "EUR",
        "GBP"
      )
    end
    let(:dates) { rates.map(&:date) }

    it "should return an array of Rates" do
      expect(rates).to be_an(Array)
      returned_classes = rates.map(&:class).uniq
      expect(returned_classes.count).to eq(1)
      expect(returned_classes[0]).to eq(Rate)
    end

    it "should make two queries to the data store" do
      allow(ExchangeRate)
        .to receive(:repository)
        .and_return(ExchangeRateRepository.new)
      rates
      # Once to get the rates from the store and the second to get the
      # dates to make sure all are present in the results.
      expect(ExchangeRate).to have_received(:repository).twice
    end

    it "should only include one rate for each day" do
      expect(dates.count).to eq(dates.uniq.count)
    end

    it "should include a rate only for weekdays and include every weekday" do
      (Date.parse("2018-11-23")..Date.parse("2018-11-27")).each do |day|
        if day.saturday? || day.sunday?
          expect(dates.include?(day.to_s)).to eq(false)
        else
          expect(dates.include?(day.to_s)).to eq(true)
        end
      end
    end

    it "should include the day at the beginning of the range" do
      expect(dates.include?("2018-11-23")).to eq(true)
    end

    it "should include the day at the end of the range" do
      expect(dates.include?("2018-11-27")).to eq(true)
    end

    context "when one of the requested rates is missing from the data store" do
      let(:rates) {
        ExchangeRate.rates_between(
          Date.parse("2018-11-23"),
          Date.parse("2018-11-27"),
          "CAD",
          "EUR"
        )
      }

      before(:context) do
        # Ensure that the first and last rates are set
        # (by using find_rate as a proxy of creation).
        ExchangeRate.find_rate("2018-11-23", "CAD", "EUR")
        ExchangeRate.find_rate("2018-11-27", "CAD", "EUR")
        ExchangeRate.repository.refresh_index!
      end

      it "should delegate to .find_rate to find the missing rate" do
        allow(ExchangeRate)
          .to receive(:find_rate)
          .and_return(ExchangeRate.find_rate("2018-11-26", "CAD", "EUR"))
        rates
        expect(ExchangeRate).to have_received(:find_rate).once
      end

      it "should rteurn correctly ordered results" do
        expect(rates.map(&:date)).to match_array(["2018-11-23", "2018-11-26", "2018-11-27"])
      end
    end
  end

  describe ".at" do
    it "delegates to .find_rate" do
      allow(ExchangeRate)
        .to receive(:find_rate)
        .and_return(ExchangeRate.find_rate("2018-11-27", "EUR", "GBP"))
      ExchangeRate.at("2018-11-27", "EUR", "GBP")
      expect(ExchangeRate).to have_received(:find_rate)
    end

    context "when the rate exists in the data store" do
      it "should return the value of the rate" do
        value = ExchangeRate.at(Date.parse("2018-11-27"), "EUR", "GBP")
        expect(value).to eq("0.88748")
      end
    end

    context "when the rate does not exist in the data store" do
      it "should raise an error" do
        expect {
          ExchangeRate.at(Time.zone.today, "III", "JJJ")
        }.to raise_error(
          ExchangeRate::NotFound,
          "The exchange rate for III in JJJ on #{Time.zone.today} is unknown."
        )
      end
    end
  end

  describe ".between" do
    let(:rate_values) do
      ExchangeRate.between(
        Date.parse("2018-11-23"),
        Date.parse("2018-11-27"),
        "EUR",
        "GBP"
      )
    end
    let(:dates) { rate_values.keys }

    it "should return a Hash" do
      expect(rate_values).to be_an(Hash)
    end

    it "should include Hashes with the correct structure" do
      rate_values.each do |key, value|
        expect(Date.parse(key).to_s).to eq(key)
        expect(value.to_f.to_s).to eq(value)
      end
    end

    it "should make two queries to the data store" do
      allow(ExchangeRate)
        .to receive(:repository)
        .and_return(ExchangeRateRepository.new)
      rate_values
      # Once to get the rates from the store and the second to get the
      # dates to make sure all are present in the results.
      expect(ExchangeRate).to have_received(:repository).twice
    end

    it "should only include one rate for each day" do
      expect(dates.count).to eq(dates.uniq.count)
    end

    it "should include a rate only for weekdays and include every weekday" do
      (Date.parse("2018-11-23")..Date.parse("2018-11-27")).each do |day|
        if day.saturday? || day.sunday?
          expect(dates.include?(day.to_s)).to eq(false)
        else
          expect(dates.include?(day.to_s)).to eq(true)
        end
      end
    end

    it "should include the day at the beginning of the range" do
      expect(dates.include?("2018-11-23")).to eq(true)
    end

    it "should include the day at the end of the range" do
      expect(dates.include?("2018-11-27")).to eq(true)
    end
  end
end
