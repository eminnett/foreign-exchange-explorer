# frozen_string_literal: true

require "rails_helper"

RSpec.describe DatesController, type: :controller do
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

    it "returns an array of dates" do
      get :show
      res = JSON.parse(response.body)
      expect(response.code).to eq("200")
      expect(res).to be_an(Array)
      res.each do |date|
        expect { Date.parse(date) }.to_not raise_error
      end
    end

    it "returns all of the available dates" do
      get :show
      res = JSON.parse(response.body)
      expect(response.code).to eq("200")
      expect(res).to match_array(["2018-11-23", "2018-11-26", "2018-11-27"])
    end

    context "when there aren't any dates available" do
      it "returns a 404 response" do
        allow(ExchangeRate).to receive(:dates).and_return([])
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
