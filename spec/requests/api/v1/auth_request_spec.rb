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

        context 'response' do
            let!(:expected_failure_response) { 
                {
                    "status": 401,
                    "code": "UNAUTHORIZED",
                    "message": "Authentican Failed",
                    "details": "The email and password provided do not match"
                } 
            }

            # let!(:expected_successful_response) {
            #     {
            #         "status": 200,
            #         "code": "OK",
            #         "message": "Authentication Successful",
            #         "token": nil # force to fail until the JWT infrastructure is up and usable
            #     }
            # }

            let!(:correct_body) {
                {
                    "email": "#{user.email}",
                    "password": "#{user.password}"
                }.merge(required_headers)
            }
            
            it 'returns 401 if there is no password' do
                bad_request_body = correct_body.except :password
                post "/api/v1/auth", headers: required_headers, params: bad_request_body

                expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_failure_response
            end

            it 'returns 401 if there is no email' do
                bad_request_body = correct_body.except :email
                post "/api/v1/auth", headers: required_headers, params: bad_request_body

                expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_failure_response
            end

            it 'returns 401 if the password is incorrect' do
                bad_request_body = correct_body
                bad_request_body[:password] = "these_are_not_my_glasses"
                post "/api/v1/auth", headers: required_headers, params: bad_request_body

                expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_failure_response
            end

            it 'returns 401 if the password belongs to a different user' do
                other_users_password = create(:user).password
                bad_request_body = correct_body.merge({password: "#{other_users_password}"})
                post "/api/v1/auth", headers: required_headers, params: bad_request_body

                expect(JSON.parse(response.body, symbolize_names: true)).to eq expected_failure_response
            end

            it 'returns 200 if the password is correct' do 
                post "/api/v1/auth", headers: required_headers, params: correct_body

                expect(response.status).to eq 200
            end

            context "token" do

                it "contains expected payload" do
                    Timecop.freeze(Time.now)
                    hardcoded_delay = 86400
                    expected_payload =  {"data" => {"id" => user.id}, "expires" => (Time.now.to_i + hardcoded_delay)}
                    
                    post "/api/v1/auth", headers: required_headers, params: correct_body

                    token = JSON.parse(response.body)["token"]

                    decoded_token = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: ENV['JWT_STRAT'] })

                    expect(decoded_token.first).to eq expected_payload
                end

                it "contains the expected header" do
                    Timecop.freeze(Time.now)
                    expected_header =  {"alg" => ENV['JWT_STRAT']}
                    
                    post "/api/v1/auth", headers: required_headers, params: correct_body

                    token = JSON.parse(response.body)["token"]
                    decoded_token = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: ENV['JWT_STRAT'] })

                    expect(decoded_token.last).to eq expected_header
                end
            end
        end
    end
end