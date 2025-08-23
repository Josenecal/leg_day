require 'rails_helper'
require 'pry'

RSpec.describe "/api/v1/exercises", type: :request do
    let! (:user) { create :user }
    let! (:auth) {
        payload = {
            data: {
                id: user.id,
            },
            expires: Time.now.to_i + 86400
        }
        JWT.encode(payload, ENV['JWT_SECRET'], ENV['JWT_STRAT'])
    }
    let! (:required_headers) {
            {
                content_type: "application/json",
                accept: "application/json",
                authorization: auth
            }
        }

    context "GET /" do
        context "authorization" do
            it "responds 401 if auth is missing" do
                unauthorized_headers = required_headers.reject! { |k, v| k == :authorization }
                
                get "/api/v1/workouts", headers: unauthorized_headers
                expect(response.status.to_i).to eq 401
            end

            it "responds 401 if auth references a non-existant user" do
                bad_payload = {
                    data: {
                        id: 0,
                    },
                    expires: Time.now.to_i + 86400
                }
                bad_token = JWT.encode(bad_payload, ENV['JWT_SECRET'], ENV['JWT_STRAT'])
                
                get "/api/v1/workouts", headers: (required_headers.merge({authorization: bad_token}))
                expect(response.status.to_i).to eq 401
            end

            it "responds 401 if the authorization is not a vlid JWT" do
                bad_token = "#{SecureRandom.hex(15)}.#{SecureRandom.hex(25)}.#{SecureRandom.hex(25)}"
                
                get "/api/v1/workouts", headers: (required_headers.merge({authorization: bad_token}))
                expect(response.status.to_i).to eq 401
            end

            it "responds 401 if the token is expired" do
                bad_payload = {
                    data: {
                        id: 0,
                    },
                    expires: Time.now.to_i - 86400
                }
                bad_token = JWT.encode(bad_payload, ENV['JWT_SECRET'], ENV['JWT_STRAT'])
                
                get "/api/v1/workouts", headers: (required_headers.merge({authorization: bad_token}))
                expect(response.status.to_i).to eq 401
            end

            it "responds 200 if auth references an existing user" do
                get "/api/v1/workouts", headers: required_headers
                expect(response.status.to_i).to eq 200
            end
        end

        context "response" do # TODO: START HERE WITH TEST REFACTORS
            let! (:workout_1) { create :workout, user: user }
            let! (:workout_2) { create :workout, user: user }

            let! (:set_structure_1_1) { create :set_structure, workout: workout_1 }
            let! (:set_structure_1_2) { create :set_structure, workout: workout_1 }
            let! (:set_structure_2_1) { create :set_structure, workout: workout_2 }

            before { get "/api/v1/workouts", headers: required_headers }

            it "should contain a serialized list of a user's workouts" do
                workouts = JSON.parse(response.body)["data"]

                # Response should contain 2 workouts from above
                expect(workouts.count).to eq 2

                # Verify the serialized objects are the 2 workouts
                workouts.each do |workout|
                    expect(workout["type"]).to eq "workout"
                end
            end

            it "should include appropriate relationships" do
                # First Workout should contain set structures 1_1 and 1_2
                sent_workout_1 = JSON.parse(response.body)["data"].first

                # Verify isolated workout is workout_1
                expect(sent_workout_1["id"]).to eq workout_1.id.to_s

                # Should contain 2 relationships, "set_structures" and "exercises"
                expect(sent_workout_1["relationships"].keys.sort).to eq ["set_structures"]

                # Set Structures should have IDs matching set_structure_1_1 and set_structure_1_2
                wkt_1_set_structs = sent_workout_1["relationships"]["set_structures"]["data"]
                expected_ss_ids = (wkt_1_set_structs.reduce([]) {|acc, ss| acc << ss["id"].to_i }).sort
                actual_ss_ids = [set_structure_1_1.id, set_structure_1_2.id].sort

                expect(expected_ss_ids).to eq actual_ss_ids
            end

            it "only includes a user's owned workouts" do
                # Ensure workout exists associated to another user
                someone_elses_wrkt = create(:workout)
                expect(someone_elses_wrkt.user_id).not_to eq user.id

                # Get index of user's workouts again, post new workout creation
                get "/api/v1/workouts", headers: required_headers
                returned_wrkts = JSON.parse(response.body)["data"]
                returned_wrkt_ids = returned_wrkts.reduce([]) { |acc, w| acc << w["id"].to_i }

                # Returned workout IDs should be as expected and not include new workout ID
                expect(returned_wrkt_ids.include?(workout_1.id)).to be true
                expect(returned_wrkt_ids.include?(workout_2.id)).to be true
                expect(returned_wrkt_ids.include?(someone_elses_wrkt.id)).to be false
            end
        end
    end

    context "GET /:id" do
        let! (:workout_1) { create :workout, user: user }
        let! (:workout_2) { create :workout, user: user }

        let! (:set_structure_1_1) { create :set_structure, workout: workout_1 }
        let! (:set_structure_1_2) { create :set_structure, workout: workout_1 }
        let! (:set_structure_2_1) { create :set_structure, workout: workout_2 }

        context "authorization" do
            it "responds 401 if auth is missing" do
                unauthorized_headers = required_headers.reject! { |k, v| k == :authorization }
                
                get "/api/v1/workouts/#{workout_1.id}", headers: unauthorized_headers
                expect(response.status.to_i).to eq 401
            end

            it "responds 401 if auth references a non-existant user" do
                bad_payload = {
                    data: {
                        id: 0,
                    },
                    expires: Time.now.to_i + 86400
                }
                bad_token = JWT.encode(bad_payload, ENV['JWT_SECRET'], ENV['JWT_STRAT'])
                bad_user_auth = required_headers.merge(authorization: bad_token)
                
                get "/api/v1/workouts/#{workout_1.id}", headers: bad_user_auth
                expect(response.status.to_i).to eq 401
            end

            it "responds 401 if requesting a workout not belonging to a user" do
                other_user = create :user
                someone_elses_wrkt = create(:workout, user_id: other_user.id)
                get "/api/v1/workouts/#{someone_elses_wrkt.id}", headers: required_headers
                expect(response.status.to_i).to eq 404
            end

            it "responds 200 if auth references an existing user" do
                get "/api/v1/workouts", headers: required_headers
                expect(response.status.to_i).to eq 200
            end
        end

        context "response" do

            before { get "/api/v1/workouts/#{workout_1.id}", headers: required_headers }

            it "should respond 404 if requesting a workout that doesn't exist" do

            end

            it "should contain a single workout" do
                workout = JSON.parse(response.body)["data"]

                # Response should contain workout_1, hashed
                expect(workout.is_a?(Hash)).to eq true
                expect(workout["type"]).to eq "workout"
                expect(workout["id"].to_i).to eq workout_1.id
            end

            it "should include appropriate relationships" do
                # First Workout should contain set structures 1_1 and 1_2
                workout = JSON.parse(response.body)["data"]

                # Should contain 2 relationships, "set_structures" and "exercises"
                expect(workout["relationships"].keys.sort).to eq ["set_structures"]

                # Set Structures should have IDs matching set_structure_1_1 and set_structure_1_2
                wrkt_set_structs = workout["relationships"]["set_structures"]["data"]
                expected_ss_ids = (wrkt_set_structs.reduce([]) {|acc, ss| acc << ss["id"].to_i }).sort
                actual_ss_ids = [set_structure_1_1.id, set_structure_1_2.id].sort

                expect(expected_ss_ids).to eq actual_ss_ids
            end
        end
    end

    context "POST /" do
        let! (:exercise_1) { create :exercise }
        let! (:exercise_2) { create :exercise }
        let! (:ss_tid_1) { "new_#{SecureRandom.hex(4)}" }
        let! (:ss_tid_2) { "new_#{SecureRandom.hex(4)}" }

        let! (:serialized_workout) do
            {
                data: {
                    type: "workout",
                    attributes: {},
                    relationships: {
                        set_structures: {
                            data: [
                                { 
                                    type: "set_structure", 
                                    id: ss_tid_1
                                },
                                { 
                                    type: "set_structure", 
                                    id: ss_tid_2
                                }
                            ]
                        }
                    }
                },
                included: [
                    {
                        type: "set_structure",
                        id: ss_tid_1,
                        attributes: {
                            sets: "3", 
                            reps: "10", 
                            resistance: "150", 
                            resistance_unit: "1", 
                            exercise_id: "#{exercise_1.id}"
                        }
                    },
                    {
                        type: "set_structure",
                        id: ss_tid_2,
                        attributes: {
                            sets: "4", 
                            reps: "15", 
                            resistance: "5", 
                            resistance_unit: "lbs", 
                            exercise_id: "#{exercise_2.id}"
                        }
                    }
                ]
            }
        end

        context "authorization" do
            it "should reject a request sent without an authorization headers" do
                no_auth = required_headers.reject { |k, v| k.match?("authorization") }
                post "/api/v1/workouts", headers: no_auth
                expect(response.status).to eq 401
            end

            it "should reject a request sent with an invalid authorization header" do
                bad_payload = {
                    data: {
                        id: 0,
                    },
                    expires: Time.now.to_i + 86400
                }
                bad_token = JWT.encode(bad_payload, ENV['JWT_SECRET'], ENV['JWT_STRAT'])
                bad_auth = required_headers.merge(authorization: bad_token)
                post "/api/v1/workouts", headers: bad_auth
                expect(response.status).to eq 401
            end
        end


        context "errors" do

            it "should return an error if the required params for any set structure are missing" do
                bad_ss_1_attrs = serialized_workout[:included].first[:attributes]
                bad_ss_1_attrs.delete(:exercise_id)
                bad_serialization = serialized_workout
                bad_serialization[:included].first[:attributes] = bad_ss_1_attrs

                post "/api/v1/workouts", headers: required_headers, params: bad_serialization

                expect(response.status).to eq 422
            end
        end

        context "workout creation" do
            it "should create a workout from a properly serialized request" do
                expect(Workout.count).to eq 0
                expect(SetStructure.count).to eq 0

                post "/api/v1/workouts", headers: required_headers, params: serialized_workout

                expect(Workout.count).to eq 1

                workout = Workout.first
                expect(workout.set_structures.count).to eq 2
            end

            it "should serialize the new workout in the response body" do
                post "/api/v1/workouts", headers: required_headers, params: serialized_workout
                
                new_workout_id = Workout.last.id
                completed_at = Workout.last.created_at.strftime("%A, %m/%d/%Y, %I:%M%p")
                new_sets = SetStructure.all.order(id: :desc).limit(2)
                expected = {
                    data: {
                        id: new_workout_id.to_s,
                        type: "workout",
                        attributes: {
                            completed_at: completed_at
                        },
                        relationships: {
                            set_structures: {
                                data: [
                                    {id: new_sets.last.id.to_s, type: "set_structure"},
                                    {id: new_sets.first.id.to_s, type: "set_structure"}
                                ]
                            }
                        }
                    },
                    included: [
                        {
                            id: new_sets.last.id.to_s,
                            type: "set_structure",
                            attributes: {
                                sets: 3,
                                reps: 10,
                                name: new_sets.last.exercise.name,
                                resistance: "150 Kg"
                            }
                        },
                        {
                            id: new_sets.first.id.to_s,
                            type: "set_structure",
                            attributes: {
                                sets: 4,
                                reps: 15,
                                name: new_sets.first.exercise.name,
                                resistance: "5 lbs"
                            }
                        }
                    ]
                }.to_json
                expect(response.body).to eq expected
            end
            
        end
    end

    context "PATCH /:id" do
        let!(:workout) { create :workout, user_id: user.id }
        let!(:exercise_1) { create :exercise }
        let!(:exercise_2) { create :exercise }
        let!(:exercise_3) { create :exercise }
        let(:set_1) { create :set_structure, exercise_id: exercise_1.id, workout_id: workout.id, sets: 3, reps: 12, resistance: 10, resistance_unit: 0 }
        let(:set_2) { create :set_structure, exercise_id: exercise_2.id, workout_id: workout.id, sets: 3, reps: 12, resistance: 10, resistance_unit: 0}

        context "authorization" do

            it "should reject a request sent without an authorization headers" do
                no_auth = required_headers.reject { |k, v| k.match?("authorization") }
                patch "/api/v1/workouts/#{workout.id}", headers: no_auth

                expect(response.status).to eq 401
            end

            it "should reject a request sent with an invalid authorization header" do
                bad_payload = {
                    data: {
                        id: 0,
                    },
                    expires: Time.now.to_i + 86400
                }
                bad_token = JWT.encode(bad_payload, ENV['JWT_SECRET'], ENV['JWT_STRAT'])
                bad_auth = required_headers.merge(authorization: bad_token)
                patch "/api/v1/workouts/#{workout.id}", headers: bad_auth

                expect(response.status).to eq 401
            end

            it "should reject a request to patch another user's workout" do
                another_users_workout = create :workout, user_id: other_user.id
                patch "/api/v1/workouts/#{another_users_workout.id}", headers: required_headers

                expect(response.status).to eq 404
            end
        end

        context "database" do
            it "updates existing set structures sent with ID" do
                some_other_workout = create :workout
                body = {
                    data: {
                        id: "#{workout.id}",
                        type: "workout",
                        attributes: {},
                        relationships: {
                            set_structures: {
                                data: [
                                    {id: "#{set_1.id}", type: "set_structure" },
                                    {id: "#{set_2.id}", type: "set_structure" }
                                ]
                            }
                        }
                    },
                    included: [
                        {
                            id: "#{set_1.id}",
                            type: "set_structure",
                            attributes: {
                                workout_id: "#{some_other_workout.id}",
                                exercise_id: "#{exercise_3.id}",
                                sets: "10",
                                reps: "100",
                                resistance: "1000",
                                resistance_unit: "Kg",
                                delete: false
                            }
                        }
                    ]
                }

                original_set = SetStructure.find(set_1.id)

                patch "/api/v1/workouts/#{workout.id}", headers: required_headers, params: body
                expect(response.status).to eq 200

                updated_set = SetStructure.find(set_1.id)

                # ID should indicate the same record
                expect(original_set.id).to eq updated_set.id

                # Associated workout should not be different
                expect(original_set.workout_id).to eq updated_set.workout_id
                expect(original_set.id).to eq updated_set.id

                # Associated exercise should be updated
                expect(original_set.exercise_id).not_to eq updated_set.exercise_id
                expect(updated_set.exercise_id).to eq exercise_3.id

                # Sets should be updated
                expect(original_set.sets).not_to eq (updated_set.sets)
                expect(updated_set.sets).to eq 10

                # Reps should be updated
                expect(original_set.reps).not_to eq updated_set.reps
                expect(updated_set.reps).to eq 100

                # Resistance should be updated
                expect(original_set.resistance).not_to eq updated_set.resistance
                expect(updated_set.resistance).to eq 1000

                # Resistance units should be updated
                expect(original_set.resistance_unit).not_to eq updated_set.resistance_unit
                expect(updated_set.resistance_unit).to eq "Kg"
            end

            it "creates new set structures sent with id not in database" do
                body = {
                    data: {
                        id: "#{workout.id}",
                        type: "workout",
                        attributes: {},
                        relationships: {
                            set_structures: {
                                data: [
                                    {id: "#{set_1.id}", type: "set_structure" },
                                    {id: "#{set_2.id}", type: "set_structure" }
                                ]
                            }
                        }
                    },
                    included: [
                        {
                            id: "new_1234abcd",
                            type: "set_structure",
                            attributes: {
                                workout_id: "#{workout.id}",
                                exercise_id: "#{exercise_3.id}",
                                sets: "10",
                                reps: "100",
                                resistance: "1000",
                                resistance_unit: "Kg",
                                delete: "false"
                            }
                        }
                    ]
                }

                # Before request, workout should have 2 associated sets:
                expect(workout.set_structures.count).to eq 2

                patch "/api/v1/workouts/#{workout.id}", headers: required_headers, params: body

                # After request, there should be 3
                expect(workout.set_structures.count).to eq 3
                new_set = workout.set_structures.last
                expect([set_1.id, set_2.id].include? new_set.id).to be false
                expect(new_set.exercise_id).to eq exercise_3.id
            end

            it "deletes set structures sent with attribute delete: true" do
                body = {
                    data: {
                        id: "#{workout.id}",
                        type: "workout",
                        attributes: {},
                        relationships: {
                            set_structures: {
                                data: [
                                    {id: "#{set_1.id}", type: "set_structure" },
                                    {id: "#{set_2.id}", type: "set_structure" }
                                ]
                            }
                        }
                    },
                    included: [
                        {
                            id: "#{set_1.id}",
                            type: "set_structure",
                            attributes: {
                                delete: "true"
                            }
                        }
                    ]
                }

                # Before request, workout should have 2 set structures
                expect(workout.set_structures.count).to eq 2

                patch "/api/v1/workouts/#{workout.id}", headers: required_headers, params: body

                # After request, set structure 1 should be gone
                expect(workout.set_structures.count).to eq 1
                expect(workout.set_structures.pluck(:id)).to eq [set_2.id]
            end
        end

        context "response" do 
            it "should serialize the updated workout with set structures to JSON:API standard" do
                body = {
                    data: {
                        id: "#{workout.id}",
                        type: "workout",
                        attributes: {},
                        relationships: {
                            set_structures: {
                                data: [
                                    {id: "#{set_1.id}", type: "set_structure" },
                                    {id: "#{set_2.id}", type: "set_structure" }
                                ]
                            }
                        }
                    },
                    included: [
                        {
                            id: "#{set_1.id}",
                            type: "set_structure",
                            attributes: {
                                delete: "true"
                            }
                        },
                        {
                            id: "#{set_2.id}",
                            type: "set_structure",
                            attributes: {
                                workout_id: "#{workout.id}",
                                exercise_id: "#{exercise_1.id}",
                                sets: "10",
                                reps: "100",
                                resistance: "1000",
                                resistance_unit: "Kg",
                                delete: false
                            }
                        },
                        {
                            id: "new_1234abcd",
                            type: "set_structure",
                            attributes: {
                                workout_id: "#{workout.id}",
                                exercise_id: "#{exercise_3.id}",
                                sets: "10",
                                reps: "100",
                                resistance: "1000",
                                resistance_unit: "Kg",
                                delete: "false"
                            }
                        }
                    ]
                }

                patch "/api/v1/workouts/#{workout.id}", headers: required_headers, params: body

                expected = {
                    data: {
                        id: "#{workout.id}",
                        type: "workout",
                        attributes: {completed_at: "#{workout.created_at.strftime("%A, %m/%d/%Y, %I:%M%p")}"},
                        relationships: {
                            set_structures: {
                                data: [
                                    {id: "#{set_2.id}", type: "set_structure" },
                                    {id: "#{set_2.id + 1}", type: "set_structure" }
                                ]
                            }
                        }
                    },
                    included: [
                        {
                            id: "#{set_2.id}",
                            type: "set_structure",
                            attributes: {
                                sets: 10,
                                reps: 100,
                                name: "#{exercise_1.name}",
                                resistance: "1000 Kg"
                            }
                        },
                        {
                            id: "#{set_2.id + 1}",
                            type: "set_structure",
                            attributes: {
                                sets: 10,
                                reps: 100,
                                name: "#{exercise_3.name}",
                                resistance: "1000 Kg"
                            }
                        }
                    ]
                }.to_json
                
                expect(JSON.parse response.body).to eq JSON.parse expected
            end 
        end
    end

    context "DELETE /:id" do
        let!(:workout) { create :workout, user_id: user.id }
        let!(:exercise_1) { create :exercise }
        let!(:exercise_2) { create :exercise }
        let(:set_1) { create :set_structure, exercise_id: exercise_1.id, workout_id: workout.id }
        let(:set_2) { create :set_structure, exercise_id: exercise_2.id, workout_id: workout.id }

        context "authorization" do
            it "should reject a request sent without an authorization headers" do
                no_auth = required_headers.reject { |k, v| k.match?("authorization") }
                delete "/api/v1/workouts/#{workout.id}", headers: no_auth
                expect(response.status).to eq 401
            end

            it "should reject a request sent with an invalid authorization header" do
                bad_payload = {
                    data: {
                        id: 0,
                    },
                    expires: Time.now.to_i + 86400
                }
                bad_token = JWT.encode(bad_payload, ENV['JWT_SECRET'], ENV['JWT_STRAT'])
                bad_auth = required_headers.merge(authorization: bad_token)
                delete "/api/v1/workouts/#{workout.id}", headers: bad_auth
                expect(response.status).to eq 401
            end

            it "should reject a request to delete another user's workout" do
                another_users_workout = create :workout, user_id: other_user.id
                delete "/api/v1/workouts/#{another_users_workout.id}", headers: required_headers
                expect(response.status).to eq 404
            end
        end

        context "database" do
           it "should be updated to delete the indicated workout" do
                expect(Workout.find_by(id: workout.id)).not_to be nil
                
                delete "/api/v1/workouts/#{workout.id}", headers: required_headers
                
                expect(Workout.find_by(id: workout.id)).to be nil
            end
            
            it "should delete the dependent set structures as well" do
                expect(SetStructure.find_by(id: set_1.id)).not_to be nil
                expect(SetStructure.find_by(id: set_2.id)).not_to be nil
                
                delete "/api/v1/workouts/#{workout.id}", headers: required_headers

                expect(SetStructure.find_by(id: set_1.id)).to be nil
                expect(SetStructure.find_by(id: set_2.id)).to be nil
           end

           it "should not delete associated exercises" do
                expect(Exercise.find_by(id: exercise_1.id)).not_to be nil
                expect(Exercise.find_by(id: exercise_2.id)).not_to be nil

                delete "/api/v1/workouts/#{workout.id}", headers: required_headers

                expect(response.status).to be 204
                expect(Exercise.find_by(id: exercise_1.id)).not_to be nil
                expect(Exercise.find_by(id: exercise_2.id)).not_to be nil
           end
        end

        context "response" do
            it "should return 204 if successful" do
                delete "/api/v1/workouts/#{workout.id}", headers: required_headers
                expect(response.status).to eq 204
                expect(response.body).to eq ""
            end
        end
    end
end