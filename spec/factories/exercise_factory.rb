EQUIPMENT = %w[Dumbbells Kettlebells Bench Bar Plates Floor\ mat Squat\ rack]
LEVELS = %w[beginner intermediate advanced olympic chuck\ noris]

FactoryBot.define do
    factory :exercise do
        name { Faker::Lorem.word }
        equipment { EQUIPMENT.sample(rand(1..EQUIPMENT.count)) }
        category { Exercise.categories.values.sample }
        force { Faker::Lorem.word }
        level { LEVELS[rand(0..(LEVELS.count - 1))] }
        mechanic { Faker::Lorem.word }
        primary_muscles {
            acc = [] 
            rand(1..5).times { acc << Faker::Lorem.word } 
            acc 
        }
        secondary_muscles {
            acc = [] 
            rand(1..5).times { acc << Faker::Lorem.word } 
            acc 
        }
        instructions { 
            acc = [] 
            rand(1..5).times { acc << Faker::Lorem.sentence } 
            acc 
        }
        json_id { Faker::Lorem.word }

    end
end