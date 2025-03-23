require 'rails_helper'
require 'pry'

RSpec.describe '/api/v1/user' do
    context '/create endpoint' do
        it 'creates a user when given valid data' do
            post "/api/v1/users", params: {first_name: "Bob", last_name: "Belcher", email: "bob@bobsburgers.com", password: "password"}, headers: {accept: "application/json", content_type: "application/json"}
            
            expect(response.code).to eq "200"
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