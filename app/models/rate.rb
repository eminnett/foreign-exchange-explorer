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

  def initialize(attr={})
    attr[:id] = SecureRandom.uuid
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
end
