require 'pry'
class Api::V1::UsersController < ApplicationController

    def create
        new_user = User.new(new_user_params)
        if new_user.save!
            render status: 201
        else
            render status: 422
        end
    end

    private

    def new_user_params
        params.permit(:first_name, :last_name, :email, :password)
    end
end