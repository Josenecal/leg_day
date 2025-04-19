# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Seed Exercises from https://github.com/yuhonas/free-exercise-db/blob/main/dist/exercises.json

data = File.read(Rails.root.join("db/seed_data/exercises.json"))
exercises = JSON.parse(data)

exercises.each do |e|
    exercise = Exercise.new(
        name: e[:name],
        level: e[:level],
        mechanic: e[:mechanic],
        equipment: [e[:equipment]],
        primary_muscles: e[:primaryMuscles],
        secondary_muscles: e[:secondaryMuscles],
        instructions: e[:instructions],
        category: e[:category],
        json_id: e[:id]
    )
end