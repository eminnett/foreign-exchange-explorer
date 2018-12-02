# frozen_string_literal: true

class Rate
  include ActiveModel::Model
  include ActiveModel::Validations

  ATTRIBUTES = %i[
    id
    _id
    base_currency
    counter_currency
    value
    date
  ].freeze
  attr_accessor(*ATTRIBUTES)
  attr_reader :attributes

  validates :id, presence: true
  validates :base_currency, presence: true
  validates :counter_currency, presence: true
  validates :value, presence: true
  validates :date, presence: true

  def initialize(attr={})
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
    "1 #{base_currency} equalled #{value} #{counter_currency} on #{date}."
  end
end
