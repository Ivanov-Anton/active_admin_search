# frozen_string_literal: true

require 'active_admin_search/version'
require 'active_admin_search/controller_helpers'
require 'active_admin'

module ActiveAdminSearch # :nodoc:
  def active_admin_search!(options = {})
    controller do
      include ControllerHelpers
    end

    collection_action :search do
      check_dsl_options!(options)

      additional_payload = params[:additional_payload] || Array.wrap(dsl_option_for(options, :additional_payload))
      json_term_key = dsl_option_for(options, :json_term_key)
      page = params.fetch(:page, 1)
      page_size = params.fetch(:per_page) { dsl_option_for(options, :default_per_page) }
      order_clause = dsl_option_for(options, :order_clause)
      page_limit = dsl_option_for(options, :limit)
      skip_pagination = dsl_option_for(options, :skip_pagination)
      highlight = dsl_option_for(options, :highlight)
      display_method = dsl_option_for(options, :display_method)
      default_scope = Array(dsl_option_for(options, :default_scope))
      includes = Array(dsl_option_for(options, :includes))
      value_method = dsl_option_for(options, :value_method)
      search_params = clean_search_params
      search_params = apply_search_params(search_params, json_term_key)
      search_params = search_by_id(search_params, json_term_key) if search_by_id?(search_params, json_term_key)

      text_proc = build_text_payload(search_params, highlight, display_method)

      if search_params.blank?
        scope = resource_class.none
      else
        scope = end_of_association_chain
        scope = apply_default_scope(scope, default_scope) if !skip_default_scopes? && default_scope.any?
        scope = apply_search_scope(scope, params[:scope]) if params[:scope].present?
        scope = scope.includes(includes) if includes.any?
        scope = scope.order(order_clause) if order_clause
        scope = scope.page(page).per(page_size) unless skip_pagination
        scope = scope.limit(page_limit) if page_limit
        scope = apply_authorization_scope(scope)
        scope = scope.ransack(search_params).result
        scope = decorator_class.decorate_collection(scope) if decorator_class.present?
      end

      result = build_result(scope, value_method, text_proc, additional_payload)

      render json: result
    end
  end
end

ActiveAdmin::ResourceDSL.include ActiveAdminSearch
