require 'rails_helper'
require 'pry'

RSpec.describe ApplicationController, type: :controller do
    
    context 'helper methods' do

        let!(:existing_user)  { create :user }

        context '#current_user(id)' do

            it 'finds and returns a user when passed a valid user id' do
                controller.request.headers["Authorization"] =  "#{existing_user.id}"
                expect(controller.current_user()).to eq existing_user
            end

            it 'returns nil when passed an invalid user ID' do
                controller.request.headers["Authorization"] = "#{User.last.id + 1}"
                expect(controller.current_user()).to eq nil
            end

            it 'returns nil when passed no user ID' do
                expect(controller.current_user()).to eq nil
            end
        end
    end
end