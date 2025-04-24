class ApplicationController < ActionController::API

    
    def check_required_headers()
        required = ["Accept", "Content-Type"]
        missing = required.reduce([]) { |acc, h| request.headers.include?(h) ? acc : acc << h }
        # require 'pry'; binding.pry
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
        # TO-DO: This will eventually implement JWT auth and need
        # to be updated to reflect this.
        id = sanatize_auth_header
        if id
            return User.find_by(id: id)
        else
            return nil
        end
    end

    def authenticate_request()
        if current_user()
            return true
        else
            render status: 401
        end
    end

    private

    def sanatize_auth_header()
        auth = request.headers['Authorization']
        if auth.present? && auth.is_a?(String) && auth.match?(/\A\d+\z/)
            return auth.to_i
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
