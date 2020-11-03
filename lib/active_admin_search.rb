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
    endpoint = opts.fetch(:endpoint, :search)

    collection_action endpoint do
      value_method = opts.fetch(:value_method, :id)
      display_method = opts.fetch(:display_method, :display_name)
      highlight = opts.fetch(:highlight, nil)
      sub_id = opts.fetch(:sub_id, nil)
      default_scopes = Array.wrap(opts[:default_scope])
      includes = Array.wrap(opts[:includes])
      additional_fields = Array.wrap(opts.fetch(:additional_fields, []))
      process_result = opts[:process_result]

      # clean search params
      search_params = params.fetch(:q) { params.except(:controller, :action) }.dup
      search_params.delete_if { |_, v| [*v].all? { |i| i.blank? && i != false } } # like ransack does
      opts[:modify_search].call(search_params) if opts.key?(:modify_search)

      # substitute 'id:' from value for particular key
      if sub_id.present? && search_params[sub_id].present?
        search_params[sub_id] = search_params[sub_id].sub(/^id:(\d+)/, '\1')
      end

      # highlight value of particular key in response
      text_caller = if highlight.present? && search_params[highlight].present?
                      proc { |r| view_context.highlight(r.public_send(display_method), search_params[highlight]) }
                    else
                      proc { |r| r.public_send(display_method) }
                    end

      # return empty collection if search_params is empty
      if search_params.blank?
        scope = resource_class.none
      else
        scope = end_of_association_chain
        default_scopes.each { |default_scope| scope = scope.public_send(default_scope) } # apply default_scopes
        scope = scope.includes(includes) if includes.any? # apply includes
        scope = apply_authorization_scope(scope)
        scope = scope.ransack(search_params).result
      end

      result = scope.map do |s|
        {
          value: s.public_send(value_method),
          text: text_caller.call(s)
        }.merge(additional_fields.map { |key| [key, s.public_send(key)] }.to_h)
      end
      result = instance_exec(result, &process_result) if process_result.present?

      render json: result
    end
  end
end
