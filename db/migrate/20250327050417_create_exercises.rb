class CreateExercises < ActiveRecord::Migration[7.1]
  def change
    create_table :exercises do |t|
      t.string :name
      t.string :description
      t.string :muscle_groups, array: true, default: []
      t.string :equipment, array: true, default: []
      t.string :discipline
      t.integer :category, null: false
      t.timestamps
    end
  end
end
