# frozen_string_literal: true

module ResponseJsonRspecHelpers
  def response_json
    symbolize_json JSON.parse(response.body)
  rescue StandardError => e
    warn "RSpec exception: <#{e.class}> #{e.message} in Helpers#response_json"
    nil
  end

  def symbolize_json(json)
    if json.is_a?(Array)
      json.map(&:symbolize_keys)
    else
      json&.deep_symbolize_keys
    end
  end

  def pretty_response_json
    JSON.pretty_generate(response_json)
  end
end
