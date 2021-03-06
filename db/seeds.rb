# frozen_string_literal: true

base_currency = "EUR"
# A sample of data parsed from the ECB exchange rates feed
# http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml
file_path = Rails.root.join("db", "ample_data.json")
sample_data = JSON.parse(File.read(file_path))[base_currency]

sample_data.each do |data_for_day|
  date = Date.parse(data_for_day["time"])
  data_for_day["Cube"].each do |datum|
    counter_currency = datum["currency"]
    value = datum["rate"]
    rate = ExchangeRate.set(date, base_currency, counter_currency, value)
    Rails.logger.info("Set rate: #{rate}")
  end
end
