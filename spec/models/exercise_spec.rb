require 'rails_helper'

RSpec.describe Exercise, type: :model do
  context 'associations' do
    it { should have_many(:set_structures) }
    it { should have_many(:workouts).through(:set_structures) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category) }
  end

  context 'new records' do
    let! (:full_record) {
      Exercise.new(
        name: "squat", 
        muscle_groups: ["thighs","core","back"],
        equipment: ["bar", "plate weights", "squat rack"],
        discipline: "Weight Training",
        category: 0
      )
    }

    it 'saves when all fields are present' do
      expect(full_record.save!).to be_truthy
    end

    it 'saves when muscle groups is nil' do
      partial_record = full_record
      partial_record.muscle_groups = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'saves when equipment is nil' do
      partial_record = full_record
      partial_record.equipment = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'saves when discipline is nil' do
      partial_record = full_record
      partial_record.discipline = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'does not save when category is nil' do
      partial_record = full_record
      partial_record.category = nil

      expect(partial_record.save).to be false
      expect {partial_record.save!}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not save when name is nil' do
      partial_record = full_record
      partial_record.name = nil

      expect(partial_record.save).to be false
      expect {partial_record.save!}.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'category enumeration' do
    it 'associates "0" to "Aerobic"' do
      exercise = Exercise.create(
        name: "example exercise",
        category: 0
      )

      expect(exercise.category).to eq "Aerobic"
    end

    it 'associates "1" to "Resistance"' do
      exercise = Exercise.create(
        name: "example exercise",
        category: 1
      )

      expect(exercise.category).to eq "Resistance"
    end

    it 'associates "2" to "Calisthenic"' do
      exercise = Exercise.create(
        name: "example exercise",
        category: 2
      )

      expect(exercise.category).to eq "Calisthenic"
    end

    it 'associates "3" to "Flexibility"' do
      exercise = Exercise.create(
        name: "example exercise",
        category: 3
      )

      expect(exercise.category).to eq "Flexibility"
    end
  end
end
