class User < ApplicationRecord
    # Validations and Attributes
    [:first_name, :last_name, :email, :password_digest].each do |attr|
        validates attr, presence: true
    end
    validates :email, uniqueness: true   

    has_secure_password
    has_many :workouts

    # Class methods
    def self.new_record_params()
        return [:first_name, :last_name, :email, :password]
    end

    def self.updatable_params()
        return [:first_name, :last_name]
    end

end
