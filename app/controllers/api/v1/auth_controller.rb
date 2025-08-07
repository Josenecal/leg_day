require 'jwt'
class Api::V1::AuthController < ApplicationController

    def login()
        credentials = sanatize_login_info
        user = User.find_by(email: credentials["email"])
        if user && user.authenticate(credentials["password"])
            render json: successful_response(user).to_json
        else
            render json: failure_response().to_json
        end
    end

    private

    def sanatize_login_info
        params.permit(:email, :password)
    end

    def failure_response()
        {
            status: 401,
            code: "UNAUTHORIZED",
            message: "Authentican Failed",
            details: "The email and password provided do not match"
        }
    end

    def successful_response(user)
        {
            status: 200,
            code: "OK",
            message: "Authentication Successful",
            token: generate_token(user)
        }
    end

    def generate_token(user)
        payload = tokenize(user) 
        algorithm = ENV['JWT_STRAT']
        secret = ENV['JWT_SECRET']
        
        JWT.encode(payload, secret, algorithm)
    end

    def tokenize(user)
        {
            data: {
                id: user.id,
            },
            expires: "Test Value" # Come fix this later when you understand the format from the docs
        }
    end

end