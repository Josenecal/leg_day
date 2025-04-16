require 'rails_helper'

RSpec.describe "/api/v1/exercises" do
    context "GET /" do
        context "request headers" do
            it "requires generally required headers 'accepts' and 'content-type'" do

            end

            it "requires no authorization" do

            end
        end

        context "response" do
            it "returns an index of available exercises" do
                
            end

            it "pagenates results in groups of 10 via query params" do
                
            end
        end

        context "query params" do

            it "allows searching by name via query params" do

            end
        end
    end
end