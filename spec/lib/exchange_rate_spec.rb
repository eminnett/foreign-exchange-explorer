# frozen_string_literal: true

require "rails_helper"
require "rake"
Rails.application.load_tasks

RSpec.describe Rate do
  before(:context) do
    ExchangeRate.set(Date.parse("2018-11-23"), "EUR", "GBP", "0.8848")
    ExchangeRate.set(Date.parse("2018-11-26"), "EUR", "GBP", "0.8844")
    ExchangeRate.set(Date.parse("2018-11-27"), "EUR", "GBP", "0.88748")
    ExchangeRate.repository.refresh_index!
    ExchangeRate.currency_repository.refresh_index!
  end

  after(:context) do
    ExchangeRate.repository.delete_index!
    ExchangeRate.currency_repository.delete_index!
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
      expect(ExchangeRate.currencies.map(&:code)).to include("EUR", "GBP")
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
            ExchangeRate.repository.exact_match(Time.zone.today, "CCC", "DDD").count
          ).to eq(1)
        end
      end
    end

    context "when the rate does not exist in the data store" do
      it "should populate the rate data in the data store" do
        expect(
          ExchangeRate.repository.exact_match(Time.zone.today, "EEE", "FFF").count
        ).to eq(0)
        ExchangeRate.set(Time.zone.today, "EEE", "FFF", 1.2345)
        ExchangeRate.repository.refresh_index!
        expect(
          ExchangeRate.repository.exact_match(Time.zone.today, "EEE", "FFF").count
        ).to eq(1)
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
    it "should make a single query to the data store" do
      # TODO: How do I determine this?
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

  describe ".at" do
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
    it "should make a single query to the data store" do
      # TODO: How do I determine this?
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
