require "twilreapi/active_call_router/base"
require_relative "torasup"

class Twilreapi::ActiveCallRouter::UnicefIO::CallRouter < Twilreapi::ActiveCallRouter::Base
  attr_accessor :gateway, :caller_id

  def routing_instructions
    @routing_instructions ||= generate_routing_instructions
  end

  private

  def phone_call
    options[:phone_call]
  end

  def source
    phone_call.from
  end

  def destination
    phone_call.to
  end

  def generate_routing_instructions
    set_routing_variables
    gateway_configuration = gateway || fallback_gateway || {}
    gateway_name = gateway_configuration["name"]
    gateway_host = gateway_configuration["host"]
    address = normalized_destination
    address = Phony.format(
      address,
      :format => :national,
      :spaces => ""
    ) if gateway_configuration["prefix"] == false

    if gateway_name
      dial_string_path = "gateway/#{gateway_name}/#{address}"
    elsif gateway_host
      dial_string_path = "external/#{address}@#{gateway_host}"
    end

    routing_instructions = {
      "source" => caller_id,
      "destination" => normalized_destination
    }

    if dial_string_path
      routing_instructions.merge!("dial_string_path" => dial_string_path)
    else
      routing_instructions.merge!("disable_originate" => "1")
    end

    routing_instructions
  end

  def set_routing_variables
    self.caller_id = default_caller_id || source
    self.gateway = default_gateway
  end

  def fallback_gateway
    gateways["fallback"] || other_gateways.first
  end

  def default_gateway
    gateways["default"]
  end

  def other_gateways
    gateways["others"] || []
  end

  def gateways
    operator.gateways || {}
  end

  def operator
    destination_torasup_number.operator
  end

  def destination_torasup_number
    @destination_torasup_number ||= Torasup::PhoneNumber.new(normalized_destination)
  end

  def normalized_destination
    @normalized_destination ||= Phony.normalize(destination)
  end

  def default_caller_id
    self.class.configuration("default_caller_id")
  end

  def self.configuration(key)
    ENV["TWILREAPI_ACTIVE_CALL_ROUTER_UNICEF_IO_#{key.to_s.upcase}"]
  end
end
