class Workout < ApplicationRecord
    # Validations
    validates :user_id, presence: true
    belongs_to :user
    has_many :set_structures, dependent: :destroy
    has_many :exercises, through: :set_structures
    accepts_nested_attributes_for :set_structures

    def self.new_record_params()
        return [:user_id]
    end

    def self.updatable_params()
        # This may change at some point in the future, but
        # currently the workout itself is not updatable.
        return nil
    end
end
