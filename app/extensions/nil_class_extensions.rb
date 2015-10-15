# encoding: utf-8
#
#  = Extensions to NilClass
#
#  == Instance Methods
#
#  any?::   Returns false.
#  empty?:: Returns true.
#
################################################################################

class NilClass
  def any?(*_args)
    false
  end

  def empty?
    true
  end
end
