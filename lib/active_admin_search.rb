# frozen_string_literal: true

require 'active_admin_search/version'
require 'active_admin'

# nodoc
module ActiveAdminSearch
  class Error < StandardError; end
  # get root
  def self.root
    File.dirname __dir__
  end

  # The main method that should be used in your registered page
  def active_admin_search!(opts = {})
    controller do
      def clean_search_params(search_params, json_term_key)
        search_params = params.fetch(:q) { params.except(:controller, :action, json_term_key) }.dup
        search_params.delete_if do |_, v| # like ransack does
          [*v].all? do |i|
            i.blank? && i != false
          end
        end
      end

      def term_key_rename(search_params, term_key_rename, json_term_key)
        if params[json_term_key]
          search_params[term_key_rename || json_term_key] = params[json_term_key]
        end
        search_params
      end

      def search_by_id?(search_params, json_term_key)
        json_term_key.present? && search_params[json_term_key].present? && search_params[json_term_key].match?(/^id:\d+/)
      end

      def replace_term_key(search_params, json_term_key)
        search_params[:id_eq] = search_params.delete(json_term_key).sub(/^id:(\d+)/, '\1')
        search_params
      end

      def build_text_payload(search_params, highlight, display_method)
        # highlight value of particular key in response
        if highlight.present? && search_params[highlight].present?
          proc { |r| view_context.highlight(r.public_send(display_method), search_params[highlight]) }
        else
          proc { |r| r.public_send(display_method) }
        end
      end

      def init_scope
        end_of_association_chain
      end

      def apply_default_scope(scope, default_scopes)
        default_scopes.each { |default_scope| scope = scope.public_send(default_scope) }
        return scope
      end

      def apply_search_scope(scope, search_scope)
        scope = scope.public_send(search_scope) if search_scope.present? && !search_scope.include?(',')
        search_scope.split(',').each { |s| scope = scope.public_send(s) } if search_scope.present? && search_scope.include?(',')
        return scope
      end

      def apply_preload(scope, includes)
        scope = scope.includes(includes) if includes.any?
        return scope
      end

      def apply_order(scope, order_clause)
        scope.order(order_clause) if order_clause.present?
      end

      def apply_pagination(scope, limit, skip_pagination, page_number, page_size)
        if limit.present?
          scope = scope.limit(limit)
        elsif !skip_pagination
          scope = scope.page(page_number).per(page_size)
        end
        return scope
      end

      def apply_decoration_collection(scope)
        decorator_class.decorate_collection(scope)
      end

      def build_result(scope, value_method, text_caller, additional_payload)
        scope.map do |record|
          row = {
            value: record.public_send(value_method),
            text: text_caller.call(record)
          }.merge(additional_payload.first.is_a?(Proc) ? additional_payload.first.call(record) : additional_payload.map { |key| [key, record.public_send(key)] }.to_h)
          row
        end
      end
    end

    # we can't split this block into smaller chunks
    # so we just disable Metrics/BlockLength cop for it.
    collection_action :search do # rubocop:disable Metrics/BlockLength
      value_method = opts.fetch(:value_method, :id)
      display_method = opts.fetch(:display_method, :display_name)
      highlight = opts.fetch(:highlight, nil)
      default_scopes = Array.wrap(opts[:default_scope])
      skip_default_scopes = params.delete(:skip_default_scopes) || false
      includes = Array.wrap(opts[:includes])
      limit = opts.fetch(:limit, nil)
      # look at params first then to dsl method implementation
      additional_payload = params[:additional_payload] || Array.wrap(opts.fetch(:additional_payload, []))
      # by default active_admin_search! returns only 500 items.
      # to override default page size just pass default_per_page to options.
      # you can also change page size with params[:per_page] query parameter.
      # with params[:page]=2 you can retrieve next page.
      # you can return whole collection w/o pagination by providing `skip_pagination: true` option.
      skip_pagination = opts.fetch(:skip_pagination, false)
      default_per_page = opts.fetch(:default_per_page, 500)
      order_clause = opts.fetch(:order_clause, id: :desc)
      # ajaxChosen will send term key
      # which can be renamed with jsonTermKey option
      # so we can rename it in active_admin_search too.
      json_term_key = opts.fetch(:json_term_key, :term)
      # optional rename term key before putting in into ransack search
      term_key_rename = opts[:term_key_rename]

      search_scope = params[:scope]
      page_number = params[:page] || 1
      page_size = params[:per_page] || default_per_page

      search_params = clean_search_params(search_params, term_key_rename)
      search_params = term_key_rename(search_params, term_key_rename, json_term_key)
      search_params = replace_term_key(search_params, json_term_key) if search_by_id?(search_params, json_term_key)
      text_caller = build_text_payload(search_params, highlight, display_method)

      if search_params.blank?
        scope = resource_class.none
      else
        scope = init_scope
        scope = apply_default_scope(scope, default_scopes) unless skip_default_scopes
        scope = apply_search_scope(scope, search_scope)
        scope = apply_preload(scope, includes)
        scope = apply_order(scope, order_clause)
        scope = apply_pagination(scope, limit, skip_pagination, page_number, page_size)
        scope = apply_authorization_scope(scope)
        scope = scope.ransack(search_params).result
        scope = apply_decoration_collection(scope) if decorator_class.present?
      end

      result = build_result(scope, value_method, text_caller, additional_payload)

      render json: result
    end
  end
end

ActiveAdmin::ResourceDSL.include ActiveAdminSearch
