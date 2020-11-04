# frozen_string_literal: true

require 'active_admin_search/version'

# nodoc
module ActiveAdminSearch
  class Error < StandardError; end
  # get root
  def self.root
    File.dirname __dir__
  end

  # The main method that should be used in your registered page
  def active_admin_search!(opts = {})
    # we can't split this block into smaller chunks
    # so we just disable Metrics/BlockLength cop for it.
    collection_action :search do # rubocop:disable Metrics/BlockLength
    value_method = opts.fetch(:value_method, :id)
    display_method = opts.fetch(:display_method, :display_name)
    highlight = opts.fetch(:highlight, nil)
    sub_id = opts.fetch(:sub_id, nil)
    default_scopes = Array.wrap(opts[:default_scope])
    skip_default_scopes = params.delete(:skip_default_scopes) || false
    includes = Array.wrap(opts[:includes])
    limit = opts.fetch(:limit, nil)
                                 # look at params first then to dsl method implementation
    additional_fields = params[:additional_fields] || Array.wrap(opts.fetch(:additional_fields, []))
    data_payload = opts[:data_payload]
   # by default search_support returns only 500 items.
   # to override default page size just pass default_per_page to options.
   # you can also change page size with params[:per_page] query parameter.
   # with params[:page]=2 you can retrieve next page.
   # you can return whole collection w/o pagination by providing `skip_pagination: true` option.
    skip_pagination = opts.fetch(:skip_pagination, false)
    default_per_page = opts.fetch(:default_per_page, 500)
    order_clause = opts.fetch(:order_clause, id: :desc)
    # ajaxChosen will send term key
    # which can be renamed with jsonTermKey option
    # so we can rename it in search_support too.
    json_term_key = opts.fetch(:json_term_key, :term)
    # optional rename term key before putting in into ransack search
    term_key_rename = opts[:term_key_rename]

    # scope and pagination params
    search_scope = params[:scope]
    page_number = params[:page] || 1
    page_size = params[:per_page] || default_per_page

    # clean search params
    search_params = params.fetch(:q) { params.except(:controller, :action, json_term_key) }.dup
    search_params.delete_if do |_, v| # like ransack does
      [*v].all? do |i|
        i.blank? && i != false
      end
    end

    # if params has term key we will put it to search_params
    # with optional renaming of term key.
    if params[json_term_key]
      search_params[term_key_rename || json_term_key] = params[json_term_key]
    end

    # substitute 'id:' from value for particular key
    if sub_id.present? && search_params[sub_id].present? && search_params[sub_id].match?(/^id:\d+/)
      search_params[:id_eq] = search_params.delete(sub_id).sub(/^id:(\d+)/, '\1')
    end

    # highlight value of particular key in response
    if highlight.present? && search_params[highlight].present?
      text_caller = proc { |r| view_context.highlight(r.public_send(display_method), search_params[highlight]) }
    else
      text_caller = proc { |r| r.public_send(display_method) }
    end

    # return empty collection if search_params is empty
    if search_params.blank?
      scope = resource_class.none
    else
      scope = end_of_association_chain
      unless skip_default_scopes
        default_scopes.each { |default_scope| scope = scope.public_send(default_scope) }
      end
      scope = scope.public_send(search_scope) if search_scope.present?
      scope = scope.includes(includes) if includes.any? # apply includes
      scope = scope.order(order_clause) if order_clause.present?
      if limit.present?
        scope = scope.limit(limit)
      elsif !skip_pagination
        scope = scope.page(page_number).per(page_size)
      end

      scope = apply_authorization_scope(scope)
      scope = scope.ransack(search_params).result
    end
    if decorator_class.present?
      scope = decorator_class.decorate_collection(scope)
    end

    result = scope.map do |s|
      extra = data_payload&.call(s)
      row = {
          value: s.public_send(value_method),
          text: text_caller.call(s)
      }.merge(additional_fields.map { |key| [key, s.public_send(key)] }.to_h)
      row[:payload] = extra.to_json unless extra.nil?
      row
    end

    render json: result
    end
  end

end
