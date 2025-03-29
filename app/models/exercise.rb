class Exercise < ApplicationRecord
    has_many :set_structures
    has_many :workouts, through: :set_structures
    validates :name, presence: true
    validates :category, presence: true

    enum category: {
        "Aerobic" => 0,
        "Resistance" => 1,
        "Calisthenic" => 2,
        "Flexibility" => 3
    }
    def self.new_record_params()
        [:name, :muscle_groups, :equipment, :discipline, :category]
    end

    def self.updatable_params()
        [:name, :muscle_groups, :equipment, :discipline, :category]
    end
end
