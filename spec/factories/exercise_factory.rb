MUSCLE_GROUPS = %W[Neck Shoulders Chest Lats Obliques Core Back Arms Legs] 
EQUIPMENT = %w[Dumbbells Kettlebells Bench Bar Plates Floor\ mat Squat\ rack]

FactoryBot.define do
    factory :exercise do
        name { Faker::Lorem.word }
        description { Faker::Lorem.sentence }
        muscle_groups { MUSCLE_GROUPS.sample(rand(1..MUSCLE_GROUPS.count)) }
        equipment { EQUIPMENT.sample(rand(1..EQUIPMENT.count)) }
        discipline { Faker::Lorem.word }
        category { Exercise.categories.values.sample }
    end
end