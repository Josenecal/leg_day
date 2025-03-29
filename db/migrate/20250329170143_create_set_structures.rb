class CreateSetStructures < ActiveRecord::Migration[7.1]
  def change
    create_table :set_structures do |t|
      t.references :workout, null: false, foreign_key: true
      t.references :exercise, null: false, foreign_key: true
      t.integer :sets, null: false, default: 3
      t.integer :reps, null: false, default: 0
      t.timestamps
    end
  end
end
