require 'rails_helper'
require 'pry'

RSpec.describe ExerciseSerializer do
    let! (:exercise) { create :exercise }
    let! (:serialized) { ExerciseSerializer.new(exercise).serializable_hash }

    context "serializable_hash data shape" do
        
        it "should have one top-level object, :data" do
            actual_objects = serialized.keys
            expected_objects = [:data]

            expect(actual_objects).to eq (expected_objects)
        end

        context "[:data]" do

            it "should have the expected top-level objects" do
                actual_objects = serialized[:data].keys.sort
                expected_objects = [:id, :type, :attributes].sort

                expect(actual_objects).to eq expected_objects
            end

            it ":id should be an id" do
                id = serialized[:data][:id]
                pattern = /\A\d+\z/

                expect(id).to match pattern
            end

            it ":type should be \"exercise\"" do
                actual = serialized[:data][:type]
                expected = :exercise

                expect(actual).to eq expected
            end

            context "[:attributes]" do

                it "should have the expected attribute keys" do
                    actual = serialized[:data][:attributes].keys
                    expected = [
                        :name,
                        :category,
                        :equipment,
                        :level,
                        :mechanic,
                        :force,
                        :primary_muscles,
                        :secondary_muscles,
                        :instructions
                    ]

                    expect(actual).to eq expected
                end

                # Testing for key values is just testing the factory;
                # testing for key presence is sufficient at this time.
            end

            context "[:relationships]" do
                # Exercise Serialzer does not define any relationships for serialization
            end
        end
    end
end