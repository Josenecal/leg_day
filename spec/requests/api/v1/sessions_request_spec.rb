require 'rails_helper'
require 'pry'

RSpec.describe 'api/v1/sessions' do

    context 'POST /' do

        let!(:user) { create :user }

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
            
            it 'returns 401 if there is no password' do
                
            end

            it 'returns 401 if there is no email' do

            end

            it 'returns 401 if the password is incorrect' do

            end

            it 'returns 200 if the password is correct' do 

            end

        end

    end

end