class AddRemoveExerciseColumns < ActiveRecord::Migration[7.1]
  TABLE_NAME = "exercises"
  def change
    add_column TABLE_NAME, :force, :string
    add_column TABLE_NAME, :level, :string
    add_column TABLE_NAME, :mechanic, :string
    add_column TABLE_NAME, :primary_muscles, :string, array: true
    add_column TABLE_NAME, :secondary_muscles, :string, array: true
    add_column TABLE_NAME, :instructions, :string, array: true
    add_column TABLE_NAME, :json_id, :string

    remove_column TABLE_NAME, :description, :string
    remove_column TABLE_NAME, :muscle_groups, :string, array: true, default: []
    remove_column TABLE_NAME, :discipline, :string
  end
end
