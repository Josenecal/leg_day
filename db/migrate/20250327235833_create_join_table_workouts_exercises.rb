class CreateJoinTableWorkoutsExercises < ActiveRecord::Migration[7.1]
  def change
    create_join_table :workouts, :exercises do |t|
      # t.integer :workout_id
      # t.integer :exercise_id
      t.integer :sets
      t.integer :reps
      t.integer :weight
      t.integer :duration
    end
  end
end
