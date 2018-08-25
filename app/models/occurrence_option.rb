class OccurrenceOption
  include Virtus.model
  attribute :assigned_to_id, Integer

  def self.dump(option)
    option.to_hash
  end

  def self.load(option)
    new(option)
  end
end