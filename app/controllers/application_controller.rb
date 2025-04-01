class ApplicationController < ActionController::API

    def current_user()
        # TO-DO: This will eventually implement JWT auth and need
        # to be updated to reflect this.
        user_id = request.headers['Authorization']
        unless user_id.present? && user_id.match?(/\A\d+\z/)
            return nil
        else
            return User.find_by(id: user_id.to_i)
        end
    end
end
