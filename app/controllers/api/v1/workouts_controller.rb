class Api::V1::WorkoutsController < ApplicationController
    before_action :authenticate_request

    def index()
        workouts = current_user(sanatize_auth_header).workouts
        render json: WorkoutSerializer.new(workouts).serializable_hash
    end

    def show()
        # Do stuff
    end

    def create()
        # Do stuff
    end

    def update()
        # Do stuff
    end

    def destroy()
        # Do stuff
    end
end