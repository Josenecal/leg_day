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

        context '#current_user(id)' do

            it 'finds and returns a user when passed a valid user id' do

                expect(controller.current_user(existing_user.id.to_s)).to eq existing_user
            end

            it 'returns nil when passed an invalid user ID' do
                expect(controller.current_user(0)).to eq nil
            end

            it 'returns nil when passed no user ID' do
                expect(controller.current_user()).to eq nil
            end
        end
    end
end