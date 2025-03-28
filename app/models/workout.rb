class Workout < ApplicationRecord
    REQUIRED_FIELDS = []
    UPDATABLE_FIELDS = []

    def self.new_record_params()
        REQUIRED_FIELDS
    end

    def self.updatable_params()
        UPDATABLE_FIELDS
    end
end
