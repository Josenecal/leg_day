class User < ApplicationRecord
    REQUIRED_FIELDS = [:first_name, :last_name, :email, :password_digest]
    UPDATABLE_FIELDS = []

    REQUIRED_FIELDS.each do |attr|
        validates attr, presence: true
    end

    validates :email, uniqueness: true
    
    has_secure_password

    def self.new_record_params()
        REQUIRED_FIELDS
    end

    def self.updatable_params()
        UPDATABLE_FIELDS
    end
end
