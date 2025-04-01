require 'rails_helper'
require 'pry'

RSpec.describe ApplicationController, type: :controller do
    
    context 'helper methods' do

        let! (:existing_user) do
            User.create(
                    first_name: "Homer",
                    last_name: "Simpson",
                    email: "safety@springfieldnuclear.org",
                    password: "d'oh!"
                )
        end

        context '#current_user' do

            it 'finds and returns a user when authorization header' do
                controller.request.headers['Authorization'] = existing_user.id.to_s

                expect(controller.current_user).to eq existing_user
            end

            it 'returns nil when passed an invalid user ID' do
                controller.request.headers['Authorization'] = "abcdefg"

                expect(controller.current_user()).to eq nil

                controller.request.headers['Authorization'] = "#{existing_user.id}5"

                expect(controller.current_user()).to eq nil

                controller.request.headers['Authorization'] = "12#{existing_user.id}"

                expect(controller.current_user()).to eq nil
            end

            it 'returns nil when passed no auth header' do
                controller.request.headers['Authorization'] = nil

                expect(controller.current_user()).to eq nil
            end
        end
    end
end