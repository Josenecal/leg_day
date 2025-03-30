require 'rails_helper'

RSpec.describe Workout, type: :model do
  let! (:user) {
    User.create(
      first_name: "Leopold",
      last_name: "Loggle",
      email: "leopold.loggle@logglesgeneral.wart",
      password: "gains"
    )
  }

  let! (:exercise_1) {
    Exercise.create(
      name: "squats",
      category: 0
    )
  }

  let! (:exercise_2) {
    Exercise.create(
      name: "warmup run",
      category: 1
    )
  }

  let! (:exercise_3) {
    Exercise.create(
      name: "dumbbell curls",
      category: 1
    )
  }
  
  context 'association' do
    it { should belong_to(:user) }
    it { should have_many(:set_structures).dependent(:destroy) }
    it { should have_many(:exercises).through(:set_structures) }

    it 'requires a valid user id to save' do
      valid_workout = Workout.new(user_id: user.id)
      invalid_workout = Workout.new(user_id: 0)

      expect(valid_workout.save).to be_truthy
      expect(invalid_workout.save).to be false
    end

    it 'has many exercises through set_structures' do
      workout = Workout.create(
        user_id: user.id,
      )

      expect(workout.exercises.count).to eq 0

      workout.set_structures.create(exercise_id: exercise_1.id)
      expect(workout.exercises.count).to be 1
      expect(workout.set_structures.count).to be 1

      workout.set_structures.create(exercise_id: exercise_2.id)
      expect(workout.exercises.count).to be 2
      expect(workout.set_structures.count).to be 2
    end

    it 'destroys set_structures when deleted without destroying exercises' do
      workout = Workout.create(
        user_id: user.id,
      )
      workout.set_structures.create(exercise_id: exercise_1.id)
      workout.set_structures.create(exercise_id: exercise_2.id)

      expect(Exercise.all.count).to eq 3
      expect(SetStructure.all.count).to eq 2
      expect(Workout.all.count).to eq 1

      workout.destroy

      expect(Workout.all.count).to eq 0
      expect(SetStructure.all.count).to eq 0
      expect(Exercise.all.count).to eq 3
    end
  end

  context 'validations' do
    it { should validate_presence_of(:user_id) }
  end

  context 'database table' do
    it { should have_db_column(:user_id).of_type(:integer) }
    it { should have_db_column(:created_at).of_type(:datetime) }
    it { should have_db_column(:updated_at).of_type(:datetime) }
  end

  context 'class methods' do
    context '::new_record_params' do
      it 'should return all required fields for a new user' do
        expected = [:user_id]
        actual = Workout.new_record_params

        expect(actual).to eq expected
      end
    end

    context '::updatable_params' do
      it 'should return all user-updatable fields' do 
        expected = nil
        actual = Workout.updatable_params

        expect(actual).to eq expected
      end
    end
  end
end
