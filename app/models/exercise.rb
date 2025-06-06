class Exercise < ApplicationRecord
    has_many :set_structures
    has_many :workouts, through: :set_structures
    validates :name, presence: true
    validates :category, presence: true
    validates :instructions, presence: true

    enum category: {
        "strength" => 0,
        "stretching" => 1,
        "plyometrics" => 2,
        "strongman" => 3,
        "powerlifting" => 4,
        "cardio" => 5,
        "olympic weightlifting" => 6
    }

    def self.column_for(key)
        {
            name: "name", 
            category: "category", 
            level: "level"
        }[key]
    end

    def self.new_record_params()
        # return [:name, :muscle_groups, :equipment, :discipline, :category]
        # TODO - implement user-created exercises
        nil
    end

    def self.updatable_params()
        # return [:name, :muscle_groups, :equipment, :discipline, :category]
        # TODO - implement user-updatable exercises
        nil
    end
end
