class CreateExercises < ActiveRecord::Migration[7.1]
  def change
    create_table :exercises do |t|

      t.timestamps
    end
  end
end
