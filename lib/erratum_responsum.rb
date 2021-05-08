require 'erratum_responsum/version'
require 'digest'

begin
  require 'cancancan'
  require 'erratum_responsum/cancancan'
rescue LoadError
  # no-op
end

require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'

module ErratumResponsum
  extend ActiveSupport::Concern

  cattr_accessor :error_media_type
  self.error_media_type = 'application/json'

  # 400
  def bad_request(*exception)
    render json: { errors: serialize_errors(exception) },
           status: :bad_request,
           content_type: ErratumResponsum.error_media_type
  end

  # 401
  def unauthorized(*exception)
    render json: { errors: serialize_errors(exception) },
           status: :unauthorized,
           content_type: ErratumResponsum.error_media_type
  end

  # 403
  def forbidden(exception)
    render json: { errors: serialize_errors(exception) },
           status: :forbidden,
           content_type: ErratumResponsum.error_media_type
  end

  # 404
  def not_found(exception)
    if defined?(NothingAccessibleBy) && exception.message.include?('TRUE=FALSE')
      # When CanCanCan can not find a clause for an associated model, when using accessible_by, it will use TRUE=FALSE
      # instead of throwing a CanCan::AccessDenied.
      return forbidden(NothingAccessibleBy.new(exception.model))
    end

    render json: { errors: serialize_errors(exception) },
           status: :not_found,
           content_type: ErratumResponsum.error_media_type
  end

  # 405
  def method_not_allowed(exception)
    render json: { errors: serialize_errors(exception) },
           status: :method_not_allowed,
           content_type: ErratumResponsum.error_media_type
  end

  # 406
  def not_acceptable(exception)
    render json: { errors: serialize_errors(exception) },
           status: :not_acceptable,
           content_type: ErratumResponsum.error_media_type
  end

  # 409
  def conflict(exception)
    render json: { errors: serialize_errors(exception) },
           status: :conflict,
           content_type: ErratumResponsum.error_media_type
  end

  # 410
  def gone(exception)
    render json: { errors: serialize_errors(exception) },
           status: :gone,
           content_type: ErratumResponsum.error_media_type
  end

  # 415
  def unsupported_media_type(exception)
    render json: { errors: serialize_errors(exception) },
           status: :unsupported_media_type,
           content_type: ErratumResponsum.error_media_type
  end

  # 422
  def unprocessable_entity(exception)
    render json: { errors: serialize_errors(exception) },
           status: :unprocessable_entity,
           content_type: ErratumResponsum.error_media_type
  end

  # 428
  def precondition_required(exception)
    render json: { errors: serialize_errors(exception) },
           status: :precondition_required,
           content_type: ErratumResponsum.error_media_type
  end

  # 429
  def too_many_requests(exception)
    render json: { errors: serialize_errors(exception) },
           status: :too_many_requests,
           content_type: ErratumResponsum.error_media_type
  end

  # 500
  def internal_server_error(exception)
    render json: { errors: serialize_errors(exception) },
           status: :internal_server_error,
           content_type: ErratumResponsum.error_media_type
  end

  # 501
  def not_implemented(exception)
    render json: { errors: serialize_errors(exception) },
           status: :not_implemented,
           content_type: ErratumResponsum.error_media_type
  end

  def serialize_errors(errors)
    Array(errors).map do |error|
      { message: error.respond_to?(:message) ? error.message : error, code: error_code(error) }
    end
  end

  def error_code(error)
    return 'Ex' + String(error.send(:error_code)) if error.respond_to?(:error_code)
    'Gx' + Digest::MD5.hexdigest(error.class.name)
  end
end
