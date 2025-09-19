require 'rails_helper'
require 'pry'

RSpec.describe ApplicationController, type: :controller do
    
    context 'helper methods' do

        let!(:existing_user)  { create :user }
        let!(:auth) {
            payload = {
                data: {
                    id: existing_user.id,
                },
                expires: Time.now.to_i + 86400
            }
            JWT.encode(payload, ENV['JWT_SECRET'], ENV['JWT_STRAT'])
        }

        context '#current_user()' do

            it 'finds and returns a user when passed a valid user id' do
                controller.request.headers["Authorization"] =  auth
                expect(controller.current_user()).to eq existing_user
            end

            it 'returns nil when passed a valid JWT for a non-existing user' do
                payload = {
                    data: {
                        id: 0,
                    },
                    expires: Time.now.to_i + 86400
                }
                auth = JWT.encode(payload, ENV['JWT_SECRET'], ENV['JWT_STRAT'])
                controller.request.headers["Authorization"] = auth
                expect(controller.current_user()).to eq nil
            end

            it 'returns nil when passed no auth' do
                controller.request.headers["Authorization"] = nil
                expect(controller.current_user()).to eq nil
            end
        end

        context '#check_required_headers()' do
            # Since this method renders a response, it is currently being tested in 
            # request specs. TODO -> dry this out, maybe with a test-env-only route?
        end

        context '#authenticate_request()' do
            # Since this method renders a response, it is currently being tested in 
            # request specs. TODO -> dry this out, maybe with a test-env-only route?
        end

    end
end