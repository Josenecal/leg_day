require 'rails_helper'

class UserSpec

    RSpec.describe User, type: :model do
        context 'validation' do

            let! (:valid_user) {
                User.new(
                    first_name: "Homer",
                    last_name: "Simpson",
                    email: "safety@springfieldnuclear.com",
                    password: "11111"
                )
            }

            it 'passes if valid' do
                expect valid_user.save!()
            end

            it 'fails if missing first_name' do
                invalid_user = valid_user.clone
                invalid_user.first_name = nil
                
                expect {invalid_user.save!()}.to raise_error(ActiveRecord::RecordInvalid)
            end

            it 'fails if missing last_name' do
                invalid_user = valid_user.clone
                invalid_user.last_name = nil
                
                expect {invalid_user.save!()}.to raise_error(ActiveRecord::RecordInvalid)
            end

            it 'fails if missing email' do
                invalid_user = valid_user.clone
                invalid_user.email = nil
                
                expect {invalid_user.save!()}.to raise_error(ActiveRecord::RecordInvalid)
            end

            it 'fails if missing a password' do
                invalid_user = valid_user.clone
                invalid_user.password = nil
                
                expect {invalid_user.save!()}.to raise_error(ActiveRecord::RecordInvalid)
            end

            it 'fails if email is not unique' do
                invalid_user = User.new(
                    first_name: "Ned",
                    last_name: "Flanders",
                    email: valid_user.email,
                    password: "P3ac3Unt03arth"
                )
                valid_user.save!()

                expect {invalid_user.save!()}.to raise_error(ActiveRecord::RecordInvalid)
            end
        end


    end

end