class Exercise < ApplicationRecord
    has_many :set_structures
    has_many :workouts, through: :set_structures
    validates :name, presence: true
    validates :category, presence: true

    enum category: {
        "strength" => 0,
        "stretching" => 1,
        "plyometrics" => 2,
        "strongman" => 3,
        "powerlifting" => 4,
        "cardio" => 5,
        "olympic weightlifting" => 6
    }

    def self.new_record_params()
        return [:name, :muscle_groups, :equipment, :discipline, :category]
    end

    def self.updatable_params()
        return [:name, :muscle_groups, :equipment, :discipline, :category]
    end
end
