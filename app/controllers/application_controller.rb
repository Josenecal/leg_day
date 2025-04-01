class ApplicationController < ActionController::API

    def current_user()
        # TO-DO: This will eventually implement JWT auth and need
        # to be updated to reflect this.
        # require 'pry'; binding.pry
        user_id = request.headers['Authorization']
        unless user_id.present?
            return nil
        else
            return User.find_by(id: user_id.to_i)
        end
    end
end
