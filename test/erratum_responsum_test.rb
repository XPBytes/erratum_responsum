require "test_helper"

require 'erratum_responsum'
require 'active_support/rescuable'

class FakeController
  include ErratumResponsum
  include ActiveSupport::Rescuable

  attr_accessor :last_render

  def render(*_args, json: nil, status: 200, content_type: nil, **_opts)
    self.last_render = { json: json, status: status, content_type: content_type }
  end

  def boom(throwable)
    begin
      raise throwable
    rescue => exception
      rescue_with_handler(exception) || raise
    end
  end
end

class ErratumResponsumTest < Minitest::Test

  def setup
    @controller = FakeController.new
    @controller.error_media_type = 'application/vnd.xpbytes.errors.v1+json'
  end

  def test_that_it_has_a_version_number
    refute_nil ::ErratumResponsum::VERSION
  end

  class FakeForbiddenError < RuntimeError
    def initialize(message)
      super message
    end
  end

  def test_forbidden
    FakeController.rescue_from FakeForbiddenError, with: :forbidden
    @controller.error_media_type = 'application/json'
    @controller.boom(FakeForbiddenError.new('Forbidden to execute'))

    refute_nil @controller.last_render
    assert_equal :forbidden, @controller.last_render[:status]
    assert_equal 'application/json', @controller.last_render[:content_type]
    assert_equal 'Forbidden to execute', @controller.last_render[:json][:errors][0][:message]
    assert @controller.last_render[:json][:errors][0][:code].include?('Gx')
  end

  %i[bad_request not_acceptable gone conflict unsupported_media_type unprocessable_entity].each do |name|
    define_method format('test_%<name>s', name: name) do

      @random_message = SecureRandom.base64
      @random_name = "LocalError#{SecureRandom.hex}"

      local_klazz = Kernel.const_set(
        @random_name,
        Class.new(RuntimeError) do
          def initialize(message, code)
            super message
            @code = code
          end

          def error_code
            @code
          end
        end
      )

      random_code = SecureRandom.base64

      FakeController.rescue_from local_klazz, with: name
      @controller.boom(local_klazz.new(@random_message, random_code))

      refute_nil @controller.last_render
      assert_equal name, @controller.last_render[:status]
      assert_equal 'application/vnd.xpbytes.errors.v1+json', @controller.last_render[:content_type]
      assert_equal @random_message, @controller.last_render[:json][:errors][0][:message]
      assert_equal "Ex#{random_code}", @controller.last_render[:json][:errors][0][:code]
    end
  end
end
