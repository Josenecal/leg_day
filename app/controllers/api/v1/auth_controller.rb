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
            message: "Authentication successful.",
            token: generate_token(user)
        }
    end

    def generate_token(user)
        algorithm = ENV['JWT_STRAT']
        secret = ENV['JWT_SECRET']
        payload = tokenize(user) 
        JWT.encode(payload, secret, algorithm)
    end

    def tokenize(user)
        {
            data: {
                id: user.id,
            },
            expires: Time.now.to_i + format_delay()
        }
    end

    def format_delay()
        # Currently just a hard-coded 24 hours
        return 86400
    end

end