class ApplicationController < ActionController::API

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
end
