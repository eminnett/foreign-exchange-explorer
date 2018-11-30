class Currency
  include ActiveModel::Model
  include ActiveModel::Validations

  ATTRIBUTES = [
    :id,
    :_id,
    :code,
    :symbol]
  attr_accessor(*ATTRIBUTES)
  attr_reader :attributes

  validates_presence_of :id
  validates_presence_of :code

  def self.mapping
    @mapping ||= begin
      file_path = File.join(Rails.root, '/db/codes_and_symbols.json')
      JSON.parse(File.read(file_path))
    end
  end

  def initialize(attr={})
    code = attr[:code] || attr['code']
    mapping = self.class.mapping
    attr[:symbol] ||= mapping[code]['symbol'] if mapping.keys.include? code
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
    code
  end
end
