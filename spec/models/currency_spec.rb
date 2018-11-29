require 'rails_helper'

describe Currency do
  let(:code) { 'GBP' }
  let(:currency) { Currency.new(code: code)}

  describe 'validations' do
    it { should validate_presence_of(:id) }
    it { should validate_presence_of(:code) }
  end

  describe '#attributes' do
    it 'returns a hash of the instance attributes' do
      attributes = currency.attributes
      expect(attributes.keys).to eq(Currency::ATTRIBUTES.reject {|a| a == :_id})
    end
  end

  describe '#symbol' do
    it 'is formatted correctly' do
      expect(currency.symbol).to eq('£')
    end
  end

  describe '#to_s' do
    it 'is formatted correctly' do
      expect(currency.to_s).to eq(code)
    end
  end
end
