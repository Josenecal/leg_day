require 'rails_helper'
require 'pry'

RSpec.describe 'api/v1/sessions' do
    context 'POST /' do
        let!(:user) { create :user }

        let! (:required_headers) {
            {
                content_type: "application/json",
                accept: "application/json"
            }
        }

        context 'authorization' do
            # Sessions endpoint requires no authorization at this time, so there's nothing to test here
        end

        context 'response' do
            let!(:expected_failure_response) { 
                {
                    "status": 401,
                    "code": "UNAUTHORIZED",
                    "message": "Authentican Failed",
                    "details": "The email and password provided do not match"
                } 
            }

            let!(:expected_successful_response) {
                {
                    "status": 200,
                    "code": "OK",
                    "message": "Authentication Successful",
                    "token": nil # update this assertion once you have a testing solution
                }
            }

            let!(:correct_body) {
                {
                    "email": "#{user.email}",
                    "password": "#{user.password}"
                }.merge(required_headers)
            }
            
            it 'returns 401 if there is no password' do
                bad_request_body = correct_body.except :password
                post "/api/v1/auth", headers: bad_request_body.merge(required_headers)

                expect(JSON.parse(response.body)).to eq expected_failure_response
            end

            it 'returns 401 if there is no email' do
                bad_request_body = correct_body.except :email
                post "/api/v1/auth", headers: bad_request_body.merge(required_headers)

                expect(JSON.parse(response.body)).to eq expected_failure_response
            end

            it 'returns 401 if the password is incorrect' do
                bad_request_body = correct_body
                bad_request_body[:password] = "these_are_not_my_glasses"
                post "/api/v1/auth", headers: bad_request_body.merge(required_headers)

                expect(JSON.parse(response.body)).to eq expected_failure_response
            end

            it 'returns 401 if the password belongs to a different user' do
                other_users_password = create(:user).password
                bad_request_body = correct_body.merge({password: "#{other_users_password}"})
                post "/api/v1/auth", headers: bad_request_body.merge(required_headers)

                expect(JSON.parse(response.body)).to eq expected_failure_response
            end

            it 'returns 200 if the password is correct' do 
                post "/api/v1/auth", headers: correct_body

                expect(JSON.parse(response.body)).to eq expected_successful_response
            end
        end
    end
end