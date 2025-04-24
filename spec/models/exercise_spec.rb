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

  context 'database table' do
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:equipment).of_type(:string) }
    it { should have_db_column(:category).of_type(:integer) }
    it { should have_db_column(:force).of_type(:string) }
    it { should have_db_column(:level).of_type(:string) }
    it { should have_db_column(:mechanic).of_type(:string) }
    it { should have_db_column(:primary_muscles).of_type(:string) }
    it { should have_db_column(:secondary_muscles).of_type(:string) }
    it { should have_db_column(:instructions).of_type(:string) }
    it { should have_db_column(:json_id).of_type(:string) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'new records' do
    let! (:full_record) { build :exercise }

    it 'saves when all fields are present' do
      expect(full_record.save!).to be_truthy
    end

    it 'saves when primary_muscles is nil' do
      partial_record = full_record
      partial_record.primary_muscles = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'saves when secondary_muscles is nil' do
      partial_record = full_record
      partial_record.secondary_muscles = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'saves when equipment is nil' do
      partial_record = full_record
      partial_record.equipment = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'saves when force is nil' do
      partial_record = full_record
      partial_record.force = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'saves when level is nil' do
      partial_record = full_record
      partial_record.level = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'saves when mechanic is nil' do
      partial_record = full_record
      partial_record.mechanic = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'saves when json_id is nil' do
      partial_record = full_record
      partial_record.json_id = nil

      expect(partial_record.save!).to be_truthy
    end

    it 'does not save when category is nil' do
      partial_record = full_record
      partial_record.category = nil

      expect(partial_record.save).to be false
      expect {partial_record.save!}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "does not save when instructions is nil" do
      partial_record = full_record
      partial_record.instructions = nil

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
    it 'associates "0" to "strength"' do
      exercise = create(:exercise, category: 0)

      expect(exercise.category).to eq "strength"
    end

    it 'associates "1" to "stretching"' do
      exercise = create(:exercise, category: 1)

      expect(exercise.category).to eq "stretching"
    end

    it 'associates "2" to "plyometrics"' do
      exercise = create(:exercise, category: 2)

      expect(exercise.category).to eq "plyometrics"
    end

    it 'associates "3" to "strongman"' do
      exercise = create(:exercise, category: 3)

      expect(exercise.category).to eq "strongman"
    end

    it 'associates "4" to "powerlifting"' do
      exercise = create(:exercise, category: 4)

      expect(exercise.category).to eq "powerlifting"
    end

    it 'associates "5" to "cardio"' do
      exercise = create(:exercise, category: 5)

      expect(exercise.category).to eq "cardio"
    end

    it 'associates "6" to "olympic weightlifting"' do
      exercise = create(:exercise, category: 6)

      expect(exercise.category).to eq "olympic weightlifting"
    end
  end

  context 'class methods' do
    context '::new_record_params' do
      it 'should return all required fields for a new user' do
        expected = nil
        actual = Exercise.new_record_params

        expect(actual).to eq expected
      end
    end

    context '::updatable_params' do
      it 'should return all user-updatable fields' do 
        expected = nil
        actual = Exercise.updatable_params

        expect(actual).to eq expected
      end

      context "::column_for()" do 
        let(:searchable_columns) { [:name, :level, :category] }
        let(:unsearchable) { Exercise.new.attributes.keys.map { |k| :"#{k}" }.reject { |k| searchable_columns.include? k } }

        it "should return searchable columns in string format" do
          searchable_columns.each do |sym|
            expected = sym.to_s
            actual = Exercise.column_for(sym)

            expect(actual).to eq expected
          end
        end

        it "should return nil for unsearchable columns" do
          unsearchable.each do |sym|
            expect(sym.is_a? Symbol).to be true
            expect(Exercise.column_for(sym)).to eq nil
          end
        end

      end
    end
  end
end
