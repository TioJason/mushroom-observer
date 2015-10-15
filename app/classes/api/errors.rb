# encoding: utf-8

class API
  class Error < Exception
    attr_accessor :tag, :args, :fatal, :trace

    def initialize
      self.tag = self.class.name.underscore.tr("/", "_").to_sym
      self.args = {}
      self.fatal = false
      self.trace = caller
    end

    def inspect
      "#{self.class.name}(:#{tag}#{args.inspect})"
    end

    def to_s
      tag.l(args)
    end

    def t
      tag.t(args)
    end
  end

  class ObjectError < Error
    def initialize(obj)
      super()
      if obj.respond_to?(:unique_text_name)
        name = obj.unique_text_name
      elsif obj.respond_to?(:display_name)
        name = obj.display_name
      elsif obj.respond_to?(:name)
        name = obj.name
      elsif obj.respond_to?(:title)
        name = obj.title
      else
        name = '#' + obj.id
      end
      args.merge!(type: obj.type_tag, name: name)
    end
  end

  ################################################################################

  class MissingMethod < Error
  end

  class NoMethodForAction < Error
    def initialize(method, action)
      super()
      args.merge!(method: method.to_s.upcase, action: action.to_s)
    end
  end

  class BadAction < Error
    def initialize(action)
      super()
      args.merge!(action: action.to_s)
    end
  end

  class BadMethod < Error
    def initialize(method)
      super()
      args.merge!(method: method.to_s)
    end
  end

  class BadApiKey < Error
    def initialize(str)
      super()
      args.merge!(key: str.to_s)
    end
  end

  class ApiKeyNotVerified < Error
    def initialize(key)
      super()
      args.merge!(key: key.key.to_s, notes: key.notes.to_s)
    end
  end

  class UserNotVerified < Error
    def initialize(user)
      super()
      args.merge!(login: user.login)
    end
  end

  class BadVersion < Error
    def initialize(str)
      super()
      args.merge!(version: str.to_s)
    end
  end

  class RenderFailed < Error
    def initialize(error)
      super()
      msg = error.to_s + "\n" + error.backtrace.join("\n")
      args.merge!(error: msg)
    end
  end

  ################################################################################

  class MissingParameter < Error
    def initialize(arg)
      super()
      args.merge!(arg: arg.to_s)
    end
  end

  class MissingSetParameters < Error
  end

  class BadParameterValue < Error
    def initialize(str, type)
      super()
      args.merge!(val: str.to_s, type: type)
      self.tag = :"api_bad_#{type}_parameter_value"
    end
  end

  class BadLimitedParameterValue < Error
    def initialize(str, limit)
      super()
      args.merge!(val: str.to_s, limit: limit.inspect)
    end
  end

  class StringTooLong < Error
    def initialize(str, length)
      super()
      args.merge!(val: str.to_s, limit: length.inspect)
    end
  end

  class AmbiguousName < Error
    def initialize(name, others)
      super()
      args.merge!(name: name.to_s,
                  others: others.map(&:real_search_name).join(" / "))
    end
  end

  class QueryError < Error
    def initialize(error)
      super()
      args.merge!(error: error.to_s)
    end
  end

  ################################################################################

  class AbortDueToErrors < Error
  end

  class UnusedParameters < Error
    def initialize(params)
      super()
      args.merge!(params: params.map(&:to_s).sort.join(", "))
    end
  end

  class UnexpectedUpload < Error
  end

  class HelpMessage < Error
    def initialize(params)
      super()
      help = params.keys.sort_by(&:to_s).map do |arg|
        params[arg].inspect
      end.join("\n")
      args.merge!(help: help)
    end
  end

  ################################################################################

  class MustAuthenticate < Error
  end

  class MustHaveEditPermission < ObjectError
  end

  class MustHaveViewPermission < ObjectError
  end

  class MustBeAdmin < Error
    def initialize(proj)
      super()
      args.merge!(project: proj.title)
    end
  end

  class MustBeMember < ObjectError
  end

  ################################################################################

  class MissingUpload < Error
  end

  class TooManyUploads < Error
  end

  class FileMissing < Error
    def initialize(file)
      super()
      args.merge(file: file.to_s)
    end
  end

  class CouldntDownloadURL < Error
    def initialize(url, error)
      super()
      args.merge!(url: url.to_s, error: "#{error.class.name}: #{error}")
    end
  end

  class ImageUploadFailed < Error
    def initialize(img)
      super()
      args.merge!(error: img.dump_errors)
    end
  end

  ################################################################################

  class CreateFailed < ObjectError
    def initialize(obj)
      super(obj)
      args.merge!(error: obj.formatted_errors.map(&:to_s).join("; "))
    end
  end

  class DestroyFailed < ObjectError
  end

  class LatLongMustBothBeSet < Error
  end

  class MustSupplyLocationOrGPS < Error
  end

  class LocationAlreadyExists < Error
    def initialize(str)
      super()
      args.merge!(location: str.to_s)
    end
  end

  class NameAlreadyExists < Error
    def initialize(str, name)
      super()
      args.merge!(new: str.to_s, old: name.real_search_name)
    end
  end

  class NameDoesntParse < Error
    def initialize(str)
      super()
      args.merge!(name: str.to_s)
    end
  end

  class UserAlreadyExists < Error
    def initialize(str)
      super()
      args.merge!(login: str)
    end
  end

  class ObjectNotFoundById < Error
    def initialize(id, model)
      super()
      args.merge!(id: id.to_s, type: model.type_tag)
    end
  end

  class ObjectNotFoundByString < Error
    def initialize(str, model)
      super()
      args.merge!(str: str.to_s, type: model.type_tag)
    end
  end

  class ProjectTaken < Error
    def initialize(title)
      super()
      args.merge!(title: title.to_s)
    end
  end

  class TryingToSetMultipleLocationsToSameName < Error
  end

  class UserGroupTaken < Error
    def initialize(title)
      super()
      args.merge!(title: title.to_s)
    end
  end

  class CanOnlyUseThisFieldIfHasSpecimen < Error
    def initialize(field)
      super()
      args.merge!(field: field)
    end
  end

  class CanOnlyUseOneOfTheseFields < Error
    def initialize(*fields)
      super()
      args.merge!(fields: fields.join(", "))
    end
  end
end
