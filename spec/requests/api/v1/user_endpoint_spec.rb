require 'rails_helper'
require 'pry'

RSpec.describe '/api/v1/user' do
    let! (:required_params) {
        {
            first_name: "Bob",
            last_name: "Belcher",
            email: "bob@bobsburgers.com",
            password: "password"
        }
    }

    let! (:required_headers) {
        {
            content_type: "application/json",
            accept: "application/json"
        }
    }

    context '#create endpoint' do
        it 'creates a user when given valid data' do
            post "/api/v1/users", params: required_params, headers: required_headers
            
            expect(response.code).to eq "201"
        end

        it 'responds with a 400 code if missing required data' do
            missing_first_name = required_params.dup
            missing_last_name = required_params.dup
            missing_email = required_params.dup
            missing_password = required_params.dup
            
            missing_first_name.delete(:first_name)
            missing_last_name.delete(:last_name)
            missing_email.delete(:email)
            missing_password.delete(:password)
            
            post "/api/v1/users", params: missing_first_name, headers: required_headers
            expect(response.code).to eq "422"

            post "/api/v1/users", params: missing_last_name, headers: required_headers
            expect(response.code).to eq "422"

            post "/api/v1/users", params: missing_email, headers: required_headers
            expect(response.code).to eq "422"

            post "/api/v1/users", params: missing_password, headers: required_headers
            expect(response.code).to eq "422"
        end

        it 'responds 422 if email is already in database' do
            User.new(
                first_name: "Johny",
                last_name: "Pesto",
                email: required_params[:email],
                password: "inyourfacebob!"
            ).save!

            post "/api/v1/users", params: required_params, headers: required_headers

            expect(response.code).to eq "422"
        end
    end

    context '#update endpoint' do
        let!(:original_user) {
            User.create!(
                first_name: "Bob",
                last_name: "Belcher",
                email: "bob@bobsburgers.com",
                password: "thisisapassword"
            )
        }

        it 'updates the first_name and/or last_name of an existing user' do
            new_first_name = "Jimmy"
            new_last_name = "Pesto"

            # Update just the first name
            patch "/api/v1/users/#{original_user.id}", params: {first_name: new_first_name}, headers: required_headers

            updated_user = User.find(original_user.id)

            expect(updated_user.first_name).to eq new_first_name
            expect(updated_user.last_name).to eq original_user.last_name
            expect(updated_user.email).to eq original_user.email

            # Update the last name independently
            patch "/api/v1/users/#{original_user.id}", params: {last_name: new_last_name}, headers: required_headers

            updated_user = User.find(original_user.id)

            expect(updated_user.first_name).to eq new_first_name
            expect(updated_user.last_name).to eq new_last_name
            expect(updated_user.email).to eq original_user.email

            # Update both at once
            patch "/api/v1/users/#{original_user.id}", params: {first_name: original_user.first_name, last_name: original_user.last_name}, headers: required_headers

            updated_user = User.find(original_user.id)

            expect(updated_user.first_name).to eq original_user.first_name
            expect(updated_user.last_name).to eq original_user.last_name
            expect(updated_user.email).to eq original_user.email
        end

        it 'does not update email' do
            new_email = "Jimmy@PestosPizza.com"
            patch "/api/v1/users/#{original_user.id}", params: {email: new_email}, headers: required_headers

            updated_user = User.find(original_user.id)

            expect(updated_user.email).not_to eq new_email
            expect(updated_user.email).to eq original_user.email
        end

        it 'does not update password' do
            original_password = original_user.password
            new_password = "thisisanewpassword"
            patch "/api/v1/users/#{original_user.id}", params: {password: "thisisanewpassword"}, headers: required_headers
            updated_user = User.find(original_user.id)

            # Can't test password directly, so we'll authenticate the passwords instead
            expect(updated_user.authenticate(new_password)).to be false
            expect(updated_user.authenticate(original_password)).to be updated_user
        end

        it 'returns 403 if user does not exist' do
            patch "/api/v1/users/0", params: {first_name: original_user.first_name, last_name: original_user.last_name}, headers: required_headers

            expect(response.code).to eq "403"
        end
    end
end