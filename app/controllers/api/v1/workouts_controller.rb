class Api::V1::WorkoutsController < ApplicationController
    before_action :authenticate_request

    def index()
        workouts = current_user.workouts
        render json: WorkoutSerializer.new(workouts).serializable_hash
    end

    def show()
        workout = Workout.find_by(id: params[:id])
        if workout && workout.owned_by?(current_user)
            render json: WorkoutSerializer.new(workout, include: [:set_structures]).serializable_hash
        else
            render status: 404
        end
    end

    def create()
        # binding.pry
        workout = Workout.new(new_workout_params)
        if workout.save!
            render json: WorkoutSerializer.new(workout, include: [:set_structures]).serializable_hash
        else 
            render jsonapi_errors: workout.errors, status: :unprocessable_entity
        end
    end

    def update()
        workout = Workout.find(params[:id])
        if workout.present? && workout.owned_by?(current_user)
            workout.update_sets_from_params(bulk_set_structure_params, workout.id)
            render json: WorkoutSerializer.new(workout, include: [:set_structures]).serializable_hash, status: 200
        else
            render status: 404
        end
    end

    def destroy()
        # Do stuff
    end

    private

    def validate_ownership(workout_id)
        workout = Workout.find_by(id: workout_id)
        user = current_user
        if workout && user && workout.user_id == user.id
            return workout
        else
            return nil
        end
    end

    def new_workout_params()
        # Placeholder - workout_params are curerntly expected to be empty...
        workout_params = params.dig(:data, :attributes)&.permit() || {}
        # ... because User ID is currently merged from auth header!
        # TODO: Clean this up once JWT auth is in place!
        workout_params[:user_id] = sanatize_auth_header

        included = params[:included] || []
        set_structures = included
            .select { |item| item[:type] == "set_structure" }
            .map do |set_struct|
                # Help ActiveRecord understand enum by formating int as int, not a string
                # Makes code more tolerant of receiving either format
                if set_struct[:attributes][:resistance_unit].match? /\A\d+\z/
                    set_struct[:attributes][:resistance_unit] = set_struct[:attributes][:resistance_unit].to_i
                end
                set_struct[:attributes].permit(:exercise_id, :sets, :reps, :resistance, :resistance_unit) 
            end


        workout_params[:set_structures_attributes] = set_structures

        return workout_params
    end

    def bulk_set_structure_params()
        permitted = params[:included].reduce([]) do |acc, set|
            hashed = set.permit(:id, :attributes => [:sets, :reps, :resistance, :resistance_unit, :exercise_id, :delete]).to_h
            acc << hashed
        end
        # binding.pry
        return permitted
    end

end