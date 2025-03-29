require 'rails_helper'

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

        it { should validate_presence_of(:first_name) }
        it { should validate_presence_of(:last_name) }
        it { should validate_presence_of(:email) }
        it { should validate_presence_of(:password_digest) }

        it { should validate_uniqueness_of(:email) }

        it { should have_secure_password }

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

    context 'password encryption' do
        let! (:valid_user) {
            User.new(
                first_name: "Homer",
                last_name: "Simpson",
                email: "safety@springfieldnuclear.com",
                password: "11111"
            )
        }

        it 'hashes the given password' do
            given_password = valid_user.password

            valid_user.save!()
            new_record = User.find(valid_user.id)

            expect(new_record.password).to be(nil)
            expect(new_record.password_digest).not_to eq(given_password)
        end

        it 'authenticates the correct password against the password_digest' do
            given_password = valid_user.password

            valid_user.save!()
            new_record = User.find(valid_user.id)

            expect(new_record.authenticate(given_password))
        end
    end
end