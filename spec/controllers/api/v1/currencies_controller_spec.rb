require 'rails_helper'

RSpec.describe Api::V1::CurrenciesController, type: :controller do
  before(:context) do
    ExchangeRate.set(Date.parse('2018-11-23'), 'EUR', 'GBP', '0.8848')
    ExchangeRate.set(Date.parse('2018-11-26'), 'EUR', 'GBP', '0.8844')
    ExchangeRate.set(Date.parse('2018-11-27'), 'EUR', 'GBP', '0.88748')
    sleep(1.second) # Let Elasticsearch catch up.
  end

  after(:context) do
    `bundle exec rake elasticsearch:remove_data -s`
    sleep(1.second) # Let Elasticsearch catch up.
  end

  describe "GET #show" do
    it "returns json" do
      get :show
      expect(response.header['Content-Type']).to include('application/json')
    end

    it "returns an array of currencies and symbols" do
      get :show
      res = JSON.parse(response.body)
      expect(res).to be_an(Array)
      expect(res.first.keys).to match_array(['id', 'code', 'symbol'])
      currencies = res.map {|datum| datum['code']}
      symbols = res.map {|datum| datum['symbol']}
      expect(currencies).to match_array(['EUR', 'GBP'])
      expect(symbols).to match_array(['€', '£'])
    end
  end
end
