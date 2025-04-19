require 'rails_helper'
require 'pry'

RSpec.describe "/api/v1/exercises" do
    let!(:required_headers) { {"Accept" => "application/json", "Content-Type" => "application/json"} }

    context "GET /" do
        let!(:exercises) { create_list :exercise, 100 }

        context "request headers" do     

            it "requires only generally required headers, 'accepts' and 'content-type'" do
                get "/api/v1/exercises", headers: {"Accept" => "application/json", "Content-Type" => "application/json"}

                expect(response.status).to eq 200
            end

            it "responds 400 with a message if a required header is missing" do
                get "/api/v1/exercises", headers: {"Accept" => "application/json"}
                expected_message = {"error" => "Required header Content-Type is missing."}.to_json

                expect(response.status).to eq 400
                expect(response.body).to eq expected_message
            end

            it "responds 400 with a helpful message if a required header is not set to \"application/json\"" do
                get "/api/v1/exercises", headers: {"Accept" => "text/html", "Content-Type" => "text/html"}
                expected_message = {"error" => "\"Accept\" and \"Content-Type\" headers must be \"application/json\"."}.to_json

                expect(response.status).to eq 400
                expect(response.body).to eq expected_message
            end
        end

        context "response" do
            context "shape" do

                it "has the expected top-level objects" do
                    get "/api/v1/exercises", headers: required_headers

                    expected_objects = [:links, :data, :meta].sort
                    actual_objects = JSON.parse(response.body, symbolize_names: true).keys.sort

                    expect(actual_objects).to eq expected_objects
                end

                context "links" do
                    it "includes all expected pagination links" do
                        get "/api/v1/exercises", headers: required_headers
                        pagination_links = JSON.parse(response.body, symbolize_names: true)[:links].keys
                        expected_links = [:self, :first, :last, :prev, :next]
    
                        expect(pagination_links).to eq expected_links
                    end
    
                    it "has a functioning first page link" do
                        get "/api/v1/exercises", headers: required_headers
                        first_page_link = JSON.parse(response.body, symbolize_names: true)[:links][:first]
                        get first_page_link, headers: required_headers
    
                        expected_ids = Exercise.all.order("id ASC").limit(20).pluck(:id).sort
                        returned_ids = JSON.parse(response.body, symbolize_names: true)[:data].pluck(:id).map{ |id| id.to_i }.sort
    
                        expect(returned_ids).to eq expected_ids
                    end
    
                    it "has a functioning last page link" do
                        get "/api/v1/exercises", headers: required_headers
                        last_page_link = JSON.parse(response.body, symbolize_names: true)[:links][:last]
                        get last_page_link, headers: required_headers
    
                        expected_ids = Exercise.all.order("id DESC").limit(20).pluck(:id).sort
                        returned_ids = JSON.parse(response.body, symbolize_names: true)[:data].pluck(:id).map{ |id| id.to_i }.sort
    
                        expect(returned_ids).to eq expected_ids
                    end
    
                    it "has a functioning next page link" do
                        get "/api/v1/exercises", headers: required_headers
                        next_page_link = JSON.parse(response.body, symbolize_names: true)[:links][:next]
                        get next_page_link, headers: required_headers
    
                        expected_ids = Exercise.all.order("id ASC")[20..39].pluck(:id).sort # Using range 20..39 to get second page IDs
                        returned_ids = JSON.parse(response.body, symbolize_names: true)[:data].pluck(:id).map{ |id| id.to_i }.sort
    
                        expect(returned_ids).to eq expected_ids
                    end
    
                    it "has a functioning previous page link" do
                        get "/api/v1/exercises?page=4", headers: required_headers
                        previous_page_link = JSON.parse(response.body, symbolize_names: true)[:links][:prev]
                        get previous_page_link, headers: required_headers
    
                        expected_ids = Exercise.all.order("id ASC")[40..59].pluck(:id).sort # Range 40..59 should get page 3 results
                        returned_ids = JSON.parse(response.body, symbolize_names: true)[:data].pluck(:id).map{ |id| id.to_i }.sort
    
                        expect(returned_ids).to eq expected_ids
                    end
    
                    it "has a functioning this page link" do
                        get "/api/v1/exercises?page=3", headers: required_headers
                        expected_ids = JSON.parse(response.body, symbolize_names: true)[:data].pluck(:id).map{ |id| id.to_i }.sort
                        this_page_link = JSON.parse(response.body, symbolize_names: true)[:links][:self]
                        
                        get this_page_link, headers: required_headers
                        returned_ids = JSON.parse(response.body, symbolize_names: true)[:data].pluck(:id).map{ |id| id.to_i }.sort
    
                        expect(returned_ids).to eq expected_ids
                    end
    
                    it "has a functioning fisrt page link" do 
                        get "/api/v1/exercises?page=4", headers: required_headers
                        first_page_link = JSON.parse(response.body, symbolize_names: true)[:links][:first]
                        get first_page_link, headers: required_headers
    
                        expected_ids = Exercise.all.order("id ASC").limit(20).pluck(:id).sort 
                        returned_ids = JSON.parse(response.body, symbolize_names: true)[:data].pluck(:id).map{ |id| id.to_i }.sort
    
                        expect(returned_ids).to eq expected_ids
                    end
                end

                context "meta" do
                    it "has all the expected meta data" do 
                        get "/api/v1/exercises", headers: required_headers
                        expected_meta = [:current_page, :total_pages, :total_items, :per_page].sort
                        actual_meta = JSON.parse(response.body, symbolize_names: true)[:meta].keys.sort

                        expect(actual_meta).to eq expected_meta
                    end

                    it "current_page gives the current page number" do
                        get "/api/v1/exercises", headers: required_headers
                        current_page = JSON.parse(response.body, symbolize_names: true)[:meta][:current_page].to_i
                        expect(current_page).to eq 1

                        get "/api/v1/exercises?page=3", headers: required_headers
                        current_page = JSON.parse(response.body, symbolize_names: true)[:meta][:current_page].to_i
                        expect(current_page).to eq 3
                    end

                    it "total_pages gives the total page count (100/20 = 5)" do
                        get "/api/v1/exercises", headers: required_headers
                        actual_pages = JSON.parse(response.body, symbolize_names: true)[:meta][:total_pages].to_i
                        total_exercises = Exercise.count
                        per_page = Pagy::DEFAULT[:limit]
                        expected_pages = total_exercises % per_page == 0 ? total_exercises / per_page : (total_exercises / per_page) + 1 

                        expect(actual_pages).to eq expected_pages
                    end

                    it "total_items gives total exercises in DB" do
                        get "/api/v1/exercises", headers: required_headers
                        actual_items = JSON.parse(response.body, symbolize_names: true)[:meta][:total_items].to_i
                        expected_items = Exercise.count

                        expect(actual_items).to eq expected_items
                    end

                    it "per_page gives the default number of items per page" do 
                        get "/api/v1/exercises", headers: required_headers
                        actual_per = JSON.parse(response.body, symbolize_names: true)[:meta][:per_page].to_i
                        expected_per = Pagy::DEFAULT[:limit]

                        expect(actual_per).to eq expected_per
                    end
                end

                context "data" do

                    it "returns a list of exercises" do
                        get "/api/v1/exercises", headers: required_headers
        
                        types = JSON.parse(response.body, symbolize_names: true)[:data].pluck :type
                        types.each do |t|
                            expect(t).to eq "exercise"
                        end
                    end
        
                    it "pagenates results in groups of 20" do
                        get "/api/v1/exercises", headers: required_headers
        
                        total_db_count = Exercise.count
                        expect(total_db_count).to eq 100
        
                        returned_resource_count = JSON.parse(response.body, symbolize_names: true)[:data].count
                        expect(returned_resource_count).to eq 20
                    end

                    it "sends each exercise in the expected format" do
                        get "/api/v1/exercises", headers: required_headers
                        exercises = JSON.parse(response.body, symbolize_names: true)[:data]
                        exercises.each do |e|
                            expect(e.keys.sort).to eq [:id, :type, :attributes].sort
                            expect(e[:id]).to match /\A\d+\z/
                            expect(e[:type]).to eq "exercise"
                            expect(e[:attributes].keys.sort).to eq [
                                :name, 
                                :category, 
                                :equipment, 
                                :level,
                                :mechanic,
                                :force,
                                :primary_muscles,
                                :secondary_muscles,
                                :instructions
                            ].sort
                        end
                    end
                end
            end

        end
    end

    context "GET /:id" do
        let!(:exercises) { create_list :exercise, 5 }
        let!(:id) { exercises.first.id }
        context "request" do
            context "headers" do
                it "requires only generally required headers, 'accepts' and 'content-type'" do
                    get "/api/v1/exercises/#{id}", headers: {"Accept" => "application/json", "Content-Type" => "application/json"}
    
                    expect(response.status).to eq 200
                end
    
                it "responds 400 with a message if a required header is missing" do
                    get "/api/v1/exercises/#{id}", headers: {"Accept" => "application/json"}
                    expected_message = {"error" => "Required header Content-Type is missing."}.to_json
    
                    expect(response.status).to eq 400
                    expect(response.body).to eq expected_message
                end
    
                it "responds 400 with a helpful message if a required header is not set to \"application/json\"" do
                    get "/api/v1/exercises/#{id}", headers: {"Accept" => "text/html", "Content-Type" => "text/html"}
                    expected_message = {"error" => "\"Accept\" and \"Content-Type\" headers must be \"application/json\"."}.to_json
    
                    expect(response.status).to eq 400
                    expect(response.body).to eq expected_message
                end
            end
        end

        context "response" do
            context "shape" do
                it "has the expected JSON:API top level objects" do
                    get "/api/v1/exercises/#{id}", headers: required_headers

                    sent_objects = JSON.parse(response.body, symbolize_names: true).keys.sort
                    expected_objects = [:data]

                    expect(sent_objects).to eq expected_objects
                end

                context ":data" do

                    it "has the expected JSON:API keys" do
                        get "/api/v1/exercises/#{id}", headers: required_headers
                        
                        sent_data = JSON.parse(response.body, symbolize_names: true)[:data].keys.sort
                        expected_data = [:id, :type, :attributes].sort
    
                        expect(sent_data).to eq expected_data
                    end

                    it ":id is a numeric string" do
                        get "/api/v1/exercises/#{id}", headers: required_headers

                        sent_id = JSON.parse(response.body, symbolize_names: true)[:data][:id]
                        expected = /\A\d+\z/

                        expect(sent_id).to match expected
                    end

                    it ":type is sent as exercise" do
                        get "/api/v1/exercises/#{id}", headers: required_headers

                        type = JSON.parse(response.body, symbolize_names: true)[:data][:type]
                        expected = "exercise"

                        expect(type).to eq expected
                    end

                    context ":attributes" do
                        it "has the expected keys" do
                            get "/api/v1/exercises/#{id}", headers: required_headers
                        
                            sent_attrs = JSON.parse(response.body, symbolize_names: true)[:data][:attributes].keys.sort
                            expected_attrs = [
                                :name,
                                :category,
                                :equipment,
                                :level,
                                :mechanic,
                                :force,
                                :primary_muscles,
                                :secondary_muscles,
                                :instructions
                            ].sort
        
                            expect(sent_attrs).to eq expected_attrs
                        end

                        it ":name has the expected name" do
                            get "/api/v1/exercises/#{id}", headers: required_headers

                            sent_name = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:name]
                            expected_name = exercises.first.name

                            expect(sent_name).to eq expected_name
                        end

                        it ":category has the expected category" do
                            get "/api/v1/exercises/#{id}", headers: required_headers

                            actual = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:category]
                            expected = exercises.first.category

                            expect(actual).to eq expected
                        end

                        it ":equipment has the expected equipment" do
                            get "/api/v1/exercises/#{id}", headers: required_headers

                            actual = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:equipment]
                            expected = exercises.first.equipment

                            expect(actual).to eq expected
                        end

                        it ":level has the expected level" do
                            get "/api/v1/exercises/#{id}", headers: required_headers

                            actual = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:level]
                            expected = exercises.first.level

                            expect(actual).to eq expected
                        end

                        it ":mechanic has the expected mechanic" do
                            get "/api/v1/exercises/#{id}", headers: required_headers

                            actual = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:mechanic]
                            expected = exercises.first.mechanic

                            expect(actual).to eq expected
                        end

                        it ":force has the expected force" do
                            get "/api/v1/exercises/#{id}", headers: required_headers

                            actual = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:force]
                            expected = exercises.first.force

                            expect(actual).to eq expected
                        end

                        it ":primary_muscles has the expected primary_muscles" do
                            get "/api/v1/exercises/#{id}", headers: required_headers

                            actual = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:primary_muscles]
                            expected = exercises.first.primary_muscles

                            expect(actual).to eq expected
                        end

                        it ":secondary_muscles has the expected secondary_muscles" do
                            get "/api/v1/exercises/#{id}", headers: required_headers

                            actual = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:secondary_muscles]
                            expected = exercises.first.secondary_muscles

                            expect(actual).to eq expected
                        end

                        it ":instructions has the expected instructions" do
                            get "/api/v1/exercises/#{id}", headers: required_headers

                            actual = JSON.parse(response.body, symbolize_names: true)[:data][:attributes][:instructions]
                            expected = exercises.first.instructions

                            expect(actual).to eq expected
                        end
                    end
                end
            end
        end

        context "errors" do

            it "responds 404 if exercise not found" do
                get "/api/v1/exercises/0", headers: required_headers

                expected_body = {error: "Exercise #0 could not be found."}.to_json
                expected_status = 404

                expect(response.body).to eq expected_body
                expect(response.status).to eq expected_status
            end
        end
    end
end