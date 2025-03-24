class User < ApplicationRecord
    [:first_name, :last_name, :email, :password_digest].each do |required_attr|
        validates required_attr, presence: true
    end

    validates :email, uniqueness: true
    
    has_secure_password

end
