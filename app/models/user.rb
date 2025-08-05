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

    def self.token_attributes()
        return [:id] # FOR NOW, decide what else needs to go here and add above if it needs to be derrived 
    end
end
