require 'pry'
class Api::V1::UsersController < ApplicationController

    def create
        new_user = User.new(new_user_params())
        if new_user.save!
            render status: 201
        else
            render status: 422
        end
    end

    def update
        current_user = get_current_user(id: user_id())
        unless current_user
            render status: 403
        else
            current_user.update(update_user_params())
        end
    end

    private

    def new_user_params()
        params.permit(:first_name, :last_name, :email, :password)
    end

    def update_user_params()
        params.permit(:first_name, :last_name)
    end

    def user_id()
        params[:id].to_i
    end

end