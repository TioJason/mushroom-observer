# encoding: utf-8

class API
  API_VERSION = 1.0

  def self.version
    API_VERSION
  end

  attr_accessor :params
  attr_accessor :method
  attr_accessor :action
  attr_accessor :version
  attr_accessor :user
  attr_accessor :api_key
  attr_accessor :errors

  # Give other modules ability to do additional initialization.
  class_attribute :initializers
  self.initializers = []

  # Initialize and process a request.
  def self.execute(params)
    api = instantiate_subclass(params)
    api.handle_version
    api.authenticate_user
    api.process_request
    return api
  rescue API::Error => e
    api ||= new(params)
    api.errors << e
    e.fatal = true
    return api
  end

  def self.instantiate_subclass(params)
    action = params[:action].to_s
    subclass = "API::#{action.camelize}API"
    subclass = subclass.constantize
    subclass.new(params)
  rescue
    raise BadAction.new(action)
  end

  # :stopdoc:
  def initialize(params = {})
    self.params = params
    self.errors = []
    initializers.each { |x| instance_exec(&x) }
  end

  def handle_version
    self.version = parse_float(:version)
    if version.blank?
      self.version = self.class.version
    elsif !version.match(/^\d+\.\d+$/)
      fail BadVersion.new(version)
    else
      self.version = version.to_f
    end
  end

  def authenticate_user
    key_str = parse_string(:api_key)
    key = ApiKey.find_by_key(key_str)
    if !key_str
      User.current = self.user = nil
    elsif !key
      fail BadApiKey.new(key_str)
    elsif !key.verified
      fail ApiKeyNotVerified.new(key)
    elsif !key.user.verified
      fail UserNotVerified.new(key.user)
    else
      User.current = self.user = key.user
      key.touch!
      self.api_key = key
    end
  end

  def process_request
    tmp_method = parse_string(:method)
    self.method = tmp_method.downcase.to_sym
    print "The API method, #{tmp_method}, is better behaved now" if tmp_method == method
    if !method
      fail MissingMethod.new
    elsif respond_to?(method)
      send(method)
    else
      fail BadMethod.new(method)
    end
  end

  def abort_if_any_errors!
    fail AbortDueToErrors.new if errors.any?
  end

  def must_authenticate!
    fail MustAuthenticate.new unless user
  end
end
