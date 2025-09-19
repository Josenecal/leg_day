require 'pry'
class Api::V1::UsersController < ApplicationController
    before_action :authenticate_request
    skip_before_action :authenticate_request, only: [:create]

    def create
        new_user = User.new(new_user_params())
        if new_user.save!
            render json: UserSerializer.new(new_user).serializable_hash, status: 201
        else
            render status: 422
        end
    end

    def update
        user = current_user()
        if user
            user.update(update_user_params())
        else
            render status: 403
        end
    end

    def destroy
        to_destroy = current_user()
        if to_destroy
            to_destroy.destroy
            render status: 204
        else
            render status: 401
        end
    end

    private

    def new_user_params()
        params.permit(*User.new_record_params())
    end

    def update_user_params()
        params.permit(*User.updatable_params())
    end

end