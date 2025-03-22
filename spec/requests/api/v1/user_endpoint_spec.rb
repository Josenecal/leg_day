require 'rails_helper'

RSpec.describe '/api/v1/user' do
    context '/create endpoint' do
        it 'creates a user when given valid data' do
            # expect response code to be 201
            # expect response body to contain created user parameters
        end

        it 'responds with a 400 code if missing required data' do
            # expect response code to be 400
            # expect response to contain relevant error information
        end

        it 'responds 422 if email is already in database' do
            # expect response code 422 if email already exists
        end
    end
end