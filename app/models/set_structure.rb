class SetStructure < ApplicationRecord 
    belongs_to :exercise
    belongs_to :workout

    enum resistance_unit: {
        "lbs" => 0,
        "Kg" => 1
    }
end