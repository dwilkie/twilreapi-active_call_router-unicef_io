# frozen_string_literal: true

require "spec_helper"

describe Twilreapi::ActiveCallRouter::UnicefIO::CallRouter do
  include EnvHelpers

  class DummyPhoneCall
    attr_accessor :from, :to

    def initialize(attributes = {})
      self.from = attributes[:from]
      self.to = attributes[:to]
    end
  end

  let(:destination) { "+85518345678" }
  let(:source) { "339" }

  let(:asserted_destination) { destination.sub(/^\+/, "") }
  let(:asserted_caller_id) { source }
  let(:asserted_disable_originate) { nil }

  let(:phone_call_attributes) { { from: source, to: destination } }
  let(:phone_call_instance) { DummyPhoneCall.new(phone_call_attributes) }
  let(:options) { { phone_call: phone_call_instance } }

  subject { described_class.new(options) }

  def setup_scenario; end

  before do
    setup_scenario
  end

  describe "#routing_instructions" do
    let(:routing_instructions) { subject.routing_instructions }

    def assert_routing_instructions!(options = {})
      expect(routing_instructions["disable_originate"]).to eq(asserted_disable_originate) if options[:assert_disable_originate] != false
      expect(routing_instructions["source"]).to eq(asserted_caller_id) if options[:assert_source] != false
      expect(routing_instructions["destination"]).to eq(asserted_destination) if options[:assert_destination] != false

      if !asserted_disable_originate && options[:assert_dial_string_path] != false
        expect(routing_instructions["dial_string_path"]).to eq(asserted_dial_string_path)
      end
    end

    context "destination unknown" do
      let(:asserted_caller_id) { source }
      let(:asserted_disable_originate) { "1" }
      it { assert_routing_instructions! }
    end

    context "with default caller id" do
      let(:default_caller_id) { "999" }
      let(:asserted_caller_id) { default_caller_id }

      def setup_scenario
        stub_env(
          "twilreapi_active_call_router_unicef_io_default_caller_id": default_caller_id
        )
      end

      def assert_routing_instructions!
        super(assert_disable_originate: false, assert_destination: false, assert_dial_string_path: false)
      end

      it { assert_routing_instructions! }
    end

    context "Sierra Leone" do
      let(:asserted_host) { "freeswitch-private.internal.unicef.io" }
      let(:asserted_address) { "#{asserted_destination}@#{asserted_host}" }
      let(:asserted_dial_string_path) { "external/#{asserted_address}" }

      context "Africell" do
        let(:africell_number) { "+23230234567" }
        let(:destination) { africell_number }
        it { assert_routing_instructions! }
      end
    end

    context "Somalia" do
      let(:asserted_host) { "196.201.207.191" }
      let(:asserted_address) { "#{asserted_destination}@#{asserted_host}" }
      let(:asserted_dial_string_path) { "external/#{asserted_address}" }

      context "Telesom" do
        let(:telesom_number) { "+252634000613" }
        let(:destination) { telesom_number }
        it { assert_routing_instructions! }
      end

      context "Golis" do
        let(:golis_number)  { "+252904000613" }
        let(:destination) { golis_number }
        it { assert_routing_instructions! }
      end

      context "NationLink" do
        let(:nationlink_number) { "+252694000613" }
        let(:destination) { nationlink_number }
        it { assert_routing_instructions! }
      end

      context "Somtel" do
        let(:somtel_number) { "+252654000613" }
        let(:destination) { somtel_number }
        it { assert_routing_instructions! }
      end

      context "Hormuud" do
        let(:hormuud_number) { "+252614000613" }
        let(:destination) { hormuud_number }
        it { assert_routing_instructions! }
      end
    end

    context "Brazil", :focus do
      let(:asserted_host) { "187.102.153.186" }
      let(:asserted_address) { "#{asserted_destination}@#{asserted_host}" }
      let(:asserted_dial_string_path) { "external/#{asserted_address}" }

      context "Mundivox" do
        let(:brazilian_number) { "+5582999489999" }
        let(:destination) { brazilian_number }
        it { assert_routing_instructions! }
      end
    end
  end
end
