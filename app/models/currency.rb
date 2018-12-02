# frozen_string_literal: true

class Currency
  include ActiveModel::Model
  include ActiveModel::Validations

  ATTRIBUTES = %i[id _id code symbol].freeze
  attr_accessor(*ATTRIBUTES)

  validates :id, presence: true
  validates :code, presence: true

  def self.mapping
    @mapping ||= begin
      file_path = Rails.root.join("db", "codes_and_symbols.json")
      JSON.parse(File.read(file_path))
    end
  end

  def initialize(attr={})
    code = attr[:code] || attr["code"]
    mapping = self.class.mapping
    attr[:symbol] ||= mapping[code]["symbol"] if mapping.key?(code)
    attr[:id] ||= SecureRandom.uuid
    attr.each do |k, v|
      send("#{k}=", v) if ATTRIBUTES.include?(k.to_sym)
    end
  end

  def attributes
    ATTRIBUTES.each_with_object({}) do |attr, hash|
      value = send(attr)
      hash[attr] = value if value
    end
  end
  alias to_hash attributes

  def to_s
    code
  end
end
