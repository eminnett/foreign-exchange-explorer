# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExchangeRatesController, type: :controller do
  before(:context) do
    ExchangeRate.set(Date.parse("2018-11-22"), "EUR", "GBP", "0.88598")
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

  describe "GET #show" do
    it "returns json" do
      get :show, params: {base_currency: "EUR", counter_currency: "GBP"}
      expect(response.header["Content-Type"]).to include("application/json")
    end

    context "when the requested rate is missing" do
      it "returns an appropriate error message" do
        get :show, params: {
          base_currency: "EUR", counter_currency: "GBP", on: "2000-01-01"
        }
        res = JSON.parse(response.body)
        expect(res.keys).to match_array(["error"])
        expect(res["error"])
          .to eq("The exchange rate for EUR in GBP on 2000-01-01 is unknown.")
      end
    end

    context "when the 'on' date paramter is provided" do
      it "returns a single exchange rate" do
        get :show, params: {
          base_currency: "EUR", counter_currency: "GBP", on: "2018-11-26"
        }
        res = JSON.parse(response.body)
        expect(res.keys).to match_array(
          %w[id base_currency counter_currency date value]
        )
        expect(res["base_currency"]).to eq("EUR")
        expect(res["counter_currency"]).to eq("GBP")
        expect(res["date"]).to eq("2018-11-26")
        expect(res["value"]).to eq("0.8844")
      end
    end

    context "when the 'from' and 'to' date paramters are provided" do
      it "returns the exchange rates matching the date range" do
        get :show, params: {
          base_currency:    "EUR",
          counter_currency: "GBP",
          from:             "2018-11-22",
          to:               "2018-11-27"
        }
        res = JSON.parse(response.body)
        expect(res).to be_an(Array)
        expect(res.first.keys).to match_array(
          %w[id base_currency counter_currency date value]
        )
        base_currencies = res.map {|datum| datum["base_currency"] }
        counter_currencies = res.map {|datum| datum["counter_currency"] }
        dates = res.map {|datum| datum["date"] }
        values = res.map {|datum| datum["value"] }
        expect(base_currencies).to match_array(["EUR"] * 4)
        expect(counter_currencies).to match_array(["GBP"] * 4)
        expect(dates).to match_array(
          ["2018-11-22", "2018-11-23", "2018-11-26", "2018-11-27"]
        )
        expect(values)
          .to match_array(["0.88598", "0.8848", "0.8844", "0.88748"])
      end

      context "when the 'to' paramter is older than 'from'" do
        it "returns an appropriate error message" do
          get :show, params: {
            base_currency:    "EUR",
            counter_currency: "GBP",
            from:             "2018-11-27",
            to:               "2018-11-22"
          }
          res = JSON.parse(response.body)
          expect(res.keys).to match_array(["error"])
          expect(res["error"])
            .to eq("The 'from' date must be older than the 'to' date.")
        end
      end
    end
  end
end
