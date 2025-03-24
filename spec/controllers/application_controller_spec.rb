require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

    subject {ApplicationController.new}
    
    context 'helper methods' do
        context 'get current user' do

            it 'finds and returns a user when passed a valid \'id\' parameter' do
                existing_user = User.new(
                    first_name: "Homer",
                    last_name: "Simpson",
                    email: "safety@springfieldnuclear.org",
                    password: "d'oh!"
                )
                existing_user.save!

                returned = subject.get_current_user(id: existing_user.id)

                expect(returned).to eq existing_user
            end

            it 'returns nil when passed an invalid user ID' do
                expect(subject.get_current_user(id: 0)).to eq nil
            end
        end
    end
end