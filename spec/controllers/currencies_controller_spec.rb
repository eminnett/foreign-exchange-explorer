# frozen_string_literal: true

require "rails_helper"

RSpec.describe CurrenciesController, type: :controller do
  before(:context) do
    ExchangeRate.set(Date.parse("2018-11-23"), "EUR", "GBP", "0.8848")
    ExchangeRate.set(Date.parse("2018-11-26"), "EUR", "GBP", "0.8844")
    ExchangeRate.set(Date.parse("2018-11-27"), "EUR", "GBP", "0.88748")
    ExchangeRate.repository.refresh_index!
    ExchangeRate.currency_repository.refresh_index!
  end

  after(:context) do
    ExchangeRate.repository.delete_index!
    ExchangeRate.repository.create_index!
    ExchangeRate.currency_repository.delete_index!
    ExchangeRate.currency_repository.create_index!
  end

  describe "GET #show" do
    it "returns json" do
      get :show
      expect(response.header["Content-Type"]).to include("application/json")
    end

    it "returns an array of currencies and symbols" do
      get :show
      res = JSON.parse(response.body)
      expect(response.code).to eq("200")
      expect(res).to be_an(Array)
      expect(res.first.keys).to match_array(%w[id code symbol])
      currencies = res.map {|datum| datum["code"] }
      symbols = res.map {|datum| datum["symbol"] }
      expect(currencies).to match_array(%w[EUR GBP])
      expect(symbols).to match_array(["€", "£"])
    end

    context "when there aren't any currencies available" do
      it "returns a 404 response" do
        allow(ExchangeRate).to receive(:currencies).and_return([])
        get :show
        res = JSON.parse(response.body)
        expect(response.code).to eq("404")
        expect(res.keys).to match_array(%w[error message status])
        expect(res["status"]).to eq(404)
        expect(res["error"]).to eq("not_found")
        expect(res["message"])
          .to eq("The requested resource(s) could not be found.")
      end
    end
  end
end
