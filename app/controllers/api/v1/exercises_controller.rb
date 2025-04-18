class Api::V1::ExercisesController < ApplicationController
    include Pagy::Backend

    before_action :check_required_headers
    after_action { pagy_headers_merge(@pagy) if @pagy }

    def index()
        exercises = Exercise.all.order(:id)
        @pagy, @records = pagy(exercises)
        exercises = ExerciseSerializer.new(@records).serializable_hash
        exercises.merge!(meta: format_pagy_meta(), links: format_pagy_links())

        render json: exercises.to_json
    end

    private

    def format_pagy_links()
        links_hash = {
            self: url_for(page: @pagy.page),
            first: url_for(page: 1),
            last: url_for(page: @pagy.pages),
            prev: @pagy.prev ? url_for(page: @pagy.prev) : nil,
            next: @pagy.next ? url_for(page: @pagy.next) : nil
        }

        return links_hash
    end

    def format_pagy_meta()
        metadata = {
            current_page: @pagy.page,
            total_pages: @pagy.pages,
            total_items: @pagy.count,
            per_page: @pagy.in
        }
    end
end