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

  def initialize(attrs={})
    attrs = include_default_attributes(attrs)
    attrs.each do |k, v|
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

  private

  def include_default_attributes(attrs)
    code = attrs[:code] || attrs["code"]
    mapping = self.class.mapping
    attrs[:symbol] ||= mapping[code]["symbol"] if mapping.key?(code)
    attrs[:id] ||= SecureRandom.uuid
    attrs
  end
end
