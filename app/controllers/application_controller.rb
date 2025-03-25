class ApplicationController < ActionController::API

    def get_current_user(id: nil, token: nil)
        # TO-DO: modify this to find a user by ID and then
        # check that the found user has an active session with
        # a matching token to the request

        User.find_by(id: id)
    end
end
