module PropertyScopable
  extend ActiveSupport::Concern

  included do
    belongs_to :property

    default_scope { where(property_id: Property.current_id) }
  end
end