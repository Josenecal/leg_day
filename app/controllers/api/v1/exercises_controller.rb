class Api::V1::ExercisesController < ApplicationController
    include Pagy::Backend

    before_action :check_required_headers
    after_action { pagy_headers_merge(@pagy) if @pagy }

    def index()
        exercises = find_by_params
        @pagy, @records = pagy(exercises)
        exercises = ExerciseSerializer.new(@records).serializable_hash
        exercises.merge!(meta: format_pagy_meta(), links: format_pagy_links())

        render json: exercises.to_json
    end

    def show()
        exercise = find_by_id
        if exercise
            hashed_exercise = ExerciseSerializer.new(exercise).serializable_hash
            render json: hashed_exercise, status: 200
        else
            message = "Exercise ##{params[:id]} could not be found."
            render json: {"error" => message}, status: 404
        end
    end

    private

    def find_by_id()
        Exercise.find_by(id: params[:id])
    end

    def find_by_params()
        sub_queries = []
        query = format_search_query

        exercises = query.empty? ? Exercise.all.order(:id) : Exercise.where(query).order(:id)

        return exercises
    end

    def format_search_query()
        query = String.new
        
        search_params(:string).each do |key, q|
            parts = q.split(' ')
            sub_query = String.new
            parts.each do |part|
                new_part = "#{Exercise.column_for(key)} ILIKE '%#{part}%'"
                sub_query = sub_query.empty? ? new_part : sub_query + "OR " + new_part
            end
            query = query.empty? ? "(" + sub_query + ")" : query + "AND (" + sub_query + ")"
        end
        
        search_params(:enumerated).each do 
            |key, q|
            parts = q.split(' ')
            sub_query = String.new
            parts.each do |part|
                enumerated = Exercise.categories[:"#{part}"]
                next unless enumerated
                
                new_part = "#{Exercise.column_for(key)} = #{enumerated}"
                sub_query = sub_query.empty? ? new_part : sub_query + "OR " + new_part
            end
            query = query.empty? ? "(" + sub_query + ")" : query + "AND (" + sub_query + ")"
        end
        
        return query
    end

    def search_params(type = nil)
        case type
        when :string
                params.permit(:name, :level).to_h.symbolize_keys
        when :enumerated
                params.permit(:category).to_h.symbolize_keys
        end
    end

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