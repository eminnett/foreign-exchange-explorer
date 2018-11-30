class Rate
  include ActiveModel::Model
  include ActiveModel::Validations

  ATTRIBUTES = [
    :id,
    :_id,
    :base_currency,
    :counter_currency,
    :value,
    :date]
  attr_accessor(*ATTRIBUTES)
  attr_reader :attributes

  validates_presence_of :id
  validates_presence_of :base_currency
  validates_presence_of :counter_currency
  validates_presence_of :value
  validates_presence_of :date

  def initialize(attr={})
    attr[:id] ||= SecureRandom.uuid
    attr.each do |k,v|
      if ATTRIBUTES.include?(k.to_sym)
        send("#{k}=", v)
      end
    end
  end

  def attributes
    ATTRIBUTES.inject({}) do |hash, attr|
      if value = send(attr)
        hash[attr] = value
      end
      hash
    end
  end
  alias :to_hash :attributes

  def to_s
    "1 #{base_currency} equalled #{value} #{counter_currency} on #{date}."
  end
end
