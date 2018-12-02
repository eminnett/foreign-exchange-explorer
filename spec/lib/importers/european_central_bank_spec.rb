require 'rails_helper'

# TODO: None of the tests in this spec should create exchange rates
RSpec.describe Importers::EuropeanCentralBank do
  let(:data) do
    [
      {"currency": "USD", "rate": "1.1328"},
      {"currency": "JPY", "rate": "128.66"},
      {"currency": "BGN", "rate": "1.9558"},
      {"currency": "CZK", "rate": "25.914"}
    ]
  end

  describe '#settings' do
    it 'returns the importer settings' do
      settings = Importers::EuropeanCentralBank.new.settings
      expect(settings.keys).to match_array(
        [:calculate_combinations, :calculate_inverse, :silent, :latest_n_days]
      )
    end
  end

  describe '#set_exchange_rates' do
    let(:day_of_data) { [{'time': '2018-11-27', 'Cube': data}] }

    before(:context) do
      # Stop the importer from actually setting the exchange rates.
      RSpec::Mocks.with_temporary_scope do
        allow_any_instance_of(Importers::EuropeanCentralBank)
          .to receive(:set_rate)
      end
    end

    context 'when both @calculate_combinations and @calculate_inverse are false' do
      let(:importer) { Importers::EuropeanCentralBank.new(silent: true) }

      it 'has options set to the appropriate values' do
        settings = importer.settings
        expect(settings[:calculate_inverse]).to eq(false)
        expect(settings[:calculate_combinations]).to eq(false)
      end

      it 'sets one exchange rate per datum in the data' do
        expect(importer).to receive(:set_rate).exactly(data.count).times
        importer.set_exchange_rates(day_of_data.map(&:stringify_keys))
      end
    end

    context 'when @calculate_combinations is false and @calculate_inverse is true' do
      let(:importer) do
        Importers::EuropeanCentralBank.new(
          calculate_inverse: true, silent: true
        )
      end

      it 'has options set to the appropriate values' do
        settings = importer.settings
        expect(settings[:calculate_inverse]).to eq(true)
        expect(settings[:calculate_combinations]).to eq(false)
      end

      it 'sets two exchange rates per datum' do
        expect(importer).to receive(:set_rate).exactly(data.count * 2).times
        importer.set_exchange_rates(day_of_data.map(&:stringify_keys))
      end

      it 'sets the implicit exchange rate and its inverse for each datum' do
        sample_data = day_of_data.map(&:stringify_keys)
        sample_data.first['Cube'] = [
          {"currency": "USD", "rate": "1.1328"}.stringify_keys
        ]
        day = Date.parse(sample_data.first['time'])

        expect(sample_data.count).to eq(1)
        expect(importer)
          .to receive(:set_rate).with(day, 'EUR', 'USD', '1.1328')
        expect(importer)
          .to receive(:set_rate).with(day, 'USD', 'EUR', 1/1.1328)
        importer.set_exchange_rates(sample_data)
      end
    end

    context 'when @calculate_combinations is true' do
      let(:importer) do
        Importers::EuropeanCentralBank.new(
          calculate_combinations: true, silent: true
        )
      end

      it 'has options set to the appropriate values' do
        settings = importer.settings
        expect(settings[:calculate_inverse]).to eq(true)
        expect(settings[:calculate_combinations]).to eq(true)
      end

      it 'sets all combinations of exchange rates for the given data ' \
        '(including the implicit rates and their inverses)' do
        num_combinations = data.count * (data.count - 1) + data.count * 2
        expect(importer).to receive(:set_rate).exactly(num_combinations).times
        importer.set_exchange_rates(day_of_data.map(&:stringify_keys))
      end
    end
  end

  describe '#calculate_combinations!' do
    it 'modifies the data it is given' do
      copy = Marshal.load(Marshal.dump(data)).map(&:stringify_keys)
      Importers::EuropeanCentralBank.new.calculate_combinations!(copy)
      expect(copy.count).not_to eq(data.count)
    end

    it 'returns all combinations of rates based on the given data' do
      copy = Marshal.load(Marshal.dump(data)).map(&:stringify_keys)
      combinations = Importers::EuropeanCentralBank.new.calculate_combinations!(copy)

      expect(combinations.count).to eq(12)
      base_currencies = combinations.map {|c| c[:base_currency]}
      counter_currencies = combinations.map {|c| c[:counter_currency]}
      expect(base_currencies)
        .to match_array(['USD']*3 + ['JPY']*3 + ['BGN']*3 + ['CZK']*3)
      expect(counter_currencies)
        .to match_array(['USD']*3 + ['JPY']*3 + ['BGN']*3 + ['CZK']*3)
      tested_usd_jpy = tested_jpy_usd = false
      combinations.each do |c|
        expect(c[:base_currency]).to_not eq(c[:counter_currencies])
        if c[:base_currency] == 'USD' && c[:counter_currency] == 'JPY'
          tested_usd_jpy = true
          expect(c[:rate]).to eq(128.66 / 1.1328)
        elsif c[:base_currency] == 'JPY' && c[:counter_currency] == 'USD'
          tested_jpy_usd = true
          expect(c[:rate]).to eq(1.1328 / 128.66)
        end
      end
      expect(tested_usd_jpy).to eq(true)
      expect(tested_jpy_usd).to eq(true)
    end
  end
end
