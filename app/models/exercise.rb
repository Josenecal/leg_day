class Exercise < ApplicationRecord
    REQUIRED_FIELDS = []
    UPDATABLE_FIELDS = []

    has_many :workouts, through: :workouts_exercises

    def self.new_record_params()
        REQUIRED_FIELDS
    end

    def self.updatable_params()
        UPDATABLE_FIELDS
    end
end
