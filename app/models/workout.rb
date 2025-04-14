class Workout < ApplicationRecord
    # Validations
    validates :user_id, presence: true
    belongs_to :user
    has_many :set_structures, dependent: :destroy
    has_many :exercises, through: :set_structures
    accepts_nested_attributes_for :set_structures

    def owned_by?(user)
        user_id == user.id ? true : false
    end

    def update_sets_from_params(params, workout_id)
        params.each do |set|
            db_set = SetStructure.find_by(id: set[:id].to_i)
            update_attrs = sanatize_string_attrs(set)
            destroy = update_attrs.delete(:delete) == "true" ? true : false
            if db_set.present? && destroy
                db_set.destroy
            elsif db_set.present?
                db_set.update!(update_attrs)
            elsif db_set.nil?
                new_set = SetStructure.new(workout_id: workout_id, **update_attrs)
                new_set.save!
            end
        end
    end

    def self.new_record_params()
        return [:user_id]
    end

    def self.updatable_params()
        # This may change at some point in the future, but
        # currently the workout itself is not updatable.
        return nil
    end

    private

    def sanatize_string_attrs(set_hash)
        enum = set_hash[:attributes][:resistance_unit] || ""
        if enum.match? /\A\d+\z/
            # Enum sent as integer - reformat as integer
            t_hash[:attributes][:resistance_unit] = enum.to_i
        elsif SetStructure.resistance_units.keys.any? { |unit| unit.match? enum }
            # Enum sent as acceptable unit - leave as is
            # Do nothing
        else
            # Enum sent as unparsable format - delete and log
            set_hash[:attributes].delete(:resistance_unit)
            console.log("ERROR - #{enum} is not an acceptable value for SetStructure's resistance_unit attribute")
        end

        return set_hash[:attributes]
    end
end
