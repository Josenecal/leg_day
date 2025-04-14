FactoryBot.define do
    factory :set_structure do
        association :exercise
        association :workout
        sets { [*1..5].sample }
        reps { [*1..15].sample }
        resistance { [*1..100].sample }
        resistance_unit { SetStructure.resistance_units.values.sample }
    end
end