# frozen_string_literal: true

module ActiveAdminSearch
  module ControllerHelpers # :nodoc:
    DSL_DEFAULT_OPTIONS = {
      value_method: :id,
      display_method: :display_name,
      highlight: nil,
      default_scope: [],
      includes: [],
      limit: nil,
      additional_payload: [],
      skip_pagination: false,
      default_per_page: 500,
      order_clause: { id: :desc },
      json_term_key: :term,
      term_key_rename: nil
    }.freeze

    private

    def skip_default_scopes?
      params.fetch(:skip_default_scopes, false)
    end

    def check_dsl_options!(options)
      options.assert_valid_keys(DSL_DEFAULT_OPTIONS.keys)
    end

    def dsl_option_for(options, key)
      options.fetch(key) { DSL_DEFAULT_OPTIONS[key] }
    end

    def clean_search_params(json_term_key)
      search_params = params.fetch(:q) { params.except(:controller, :action, json_term_key) }.dup
      search_params.delete_if do |_, v| # like ransack does
        [*v].all? do |i|
          i.blank? && i != false
        end
      end
    end

    def apply_search_params(search_params, json_term_key)
      search_params[json_term_key] = params[json_term_key]
      search_params
    end

    def search_by_id?(search_params, json_term_key)
      search_params[json_term_key].present? && search_params[json_term_key].match?(/^id:\d+/)
    end

    def search_by_id(search_params, json_term_key)
      search_params[:id_eq] = search_params.delete(json_term_key).sub(/^id:(\d+)/, '\1')
      search_params
    end

    def build_text_payload(search_params, highlight, display_method)
      if highlight.present? && search_params[highlight].present?
        proc { |r| view_context.highlight(r.public_send(display_method), search_params[highlight]) }
      else
        proc { |r| r.public_send(display_method) }
      end
    end

    def apply_default_scope(scope, default_scopes)
      default_scopes.each { |default_scope| scope = scope.public_send(default_scope) }
      scope
    end

    def apply_search_scope(scope, search_scope)
      search_scope.split(',').each { |s| scope = scope.public_send(s) }
      scope
    end

    def build_result(scope, value_method, text_proc, payload)
      scope.map do |record|
        {
          value: record.public_send(value_method),
          text: text_proc.call(record)
        }.merge(payload_for(record, payload))
      end
    end

    def payload_for(record, payload)
      payload.first.is_a?(Proc) ? payload.first.call(record) : payload.map { |key| [key, record.public_send(key)] }.to_h
    end
  end
end
