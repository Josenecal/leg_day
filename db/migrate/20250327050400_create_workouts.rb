class CreateWorkouts < ActiveRecord::Migration[7.1]
  def change
    create_table :workouts do |t|
      t.integer :user_id
      t.timestamps
    end
  end
end
