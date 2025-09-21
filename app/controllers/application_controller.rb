class ApplicationController < ActionController::API

    
    def check_required_headers()
        required = ["Accept", "Content-Type"]
        missing = required.reduce([]) { |acc, h| request.headers.include?(h) ? acc : acc << h }
        if missing.present?
            multiple = missing.count > 1
            message = "Required #{ multiple ? "headers" : "header" } #{missing.join(", ")} #{ multiple ? "are" : "is" } missing."
            render json: {error: message}, status: 400
        elsif accept_unacceptable? || content_type_unacceptable?
            message = "\"Accept\" and \"Content-Type\" headers must be \"application/json\"."
            render json: {error: message}, status: 400
        end

        return true
    end

    def current_user()
        @current_user ||= authorized_user
    end

    def authenticate_request()
        if authorized_user()
            return true
        else
            render status: 401
        end
    end

    private

    def authorized_user()
        token = sanatize_auth_header()
        if token
            begin
                decode = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: ENV['JWT_STRAT'] })
                payload = decode.first
                id = payload["data"]["id"]
                @current_user = User.find_by(id: id)
            rescue JWT::Base64DecodeError, JWT::DecodeError => e
                @current_user = nil
            end
            return @current_user
        else
            nil
        end

    end

    def sanatize_auth_header()
        auth = request.headers['Authorization']
        if auth.present? && auth.match?(/\A[a-zA-Z0-9\-\_\.]+\z/)
            return auth
        else
            return nil
        end
    end

    def accept_unacceptable?()
        request.headers["Accept"] != "application/json"
    end

    def content_type_unacceptable?()
        request.headers["Content-Type"] != "application/json"
    end
end
