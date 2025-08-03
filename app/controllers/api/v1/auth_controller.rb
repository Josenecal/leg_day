class Api::V1::AuthController < ApplicationController

    def login()
        credentials = sanatize_login_info

        user = User.find_by(email: credentials["email"])
        if user && user.authenticate(credentials["password"])
            body = {
                "status": 200,
                "code": "OK",
                "message": "Authentication Successful",
                "token": "test_test_123" # Fix this and generate dynamically once infra is up
            }
            render json: body.to_json
        else
            render json: failure_response
        end
    end

    private

    def sanatize_login_info
        params.permit(:email, :password)
    end

    def failure_response()
        {
            "status": 401,
            "code": "UNAUTHORIZED",
            "message": "Authentican Failed",
            "details": "The email and password provided do not match"
            }.to_json
    end

end