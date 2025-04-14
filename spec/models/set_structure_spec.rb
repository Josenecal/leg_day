require 'rails_helper'

RSpec.describe SetStructure, type: :model do
    context 'associations' do
        it { should belong_to(:workout) }
        it { should belong_to(:exercise) }
      end
    
      context 'validations' do
        # Placeholder - No current validations
      end
    
      context 'database table' do
        it { should have_db_column(:workout_id) }
        it { should have_db_column(:exercise_id) }
        it { should have_db_column(:sets).of_type(:integer) }
        it { should have_db_column(:reps).of_type(:integer) }
      end
end