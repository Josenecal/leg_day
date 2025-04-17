require 'rails_helper'
require 'pry'

RSpec.describe "/api/v1/exercises" do
    context "GET /" do
        let!(:exercises) { create_list :exercise, 30 }
        let!(:required_headers) { {"Accept" => "application/json", "Content-Type" => "application/json"} }

        context "request headers" do     
            it "requires only generally required headers, 'accepts' and 'content-type'" do
                get "/api/v1/exercises", headers: {"Accept" => "application/json", "Content-Type" => "application/json"}

                expect(response.status).to eq 200
            end

            it "responds 400 if a required header is missing" do
                get "/api/v1/exercises", headers: {"Accept" => "application/json"}
                expect(response.status).to eq 400

                get "/api/v1/exercises", headers: {"Content-Type" => "application/json"}
                expect(response.status).to eq 400

                get "/api/v1/exercises", headers: {}
                expect(response.status).to eq 400
            end

            it "responds 400 if a required header is not set to \"application/json\"" do
                get "/api/v1/exercises", headers: {"Accept" => "text/html", "Content-Type" => "text/html"}
                # binding.pry
                expect(response.status).to eq 400
            end

            it "includes a helpful error message for header issues" do

            end
        end

        context "response" do
            it "returns a list of exercises" do
                get "/api/v1/exercises", headers: required_headers

                types = JSON.parse(response.body, symbolize_names: true)[:data].pluck :type
                types.each do |t|
                    expect(t).to eq "exercise"
                end
            end

            it "pagenates results in groups of 20 via query params" do
                get "/api/v1/exercises", headers: required_headers

                resource_count = JSON.parse(response.body, symbolize_names: true)[:data].count

                expect(resource_count).to eq 20
            end
        end

        context "query params" do

            it "allows searching by name via query params" do

            end
        end
    end
end