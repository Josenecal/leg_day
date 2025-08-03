class Api::V1::AuthController < ApplicationController

    def login()
        render json: {
            "test": "success"
        }
    end

end