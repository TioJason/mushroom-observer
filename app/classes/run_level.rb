# encoding: utf-8

# Class used by "rake location", QueuedEmail and autologger (in AbstractModel)
# to turn event logging and email notifications off.
class RunLevel
  @@runlevel = :normal

  def self.normal
    @@runlevel = :normal
  end

  def self.silent
    @@runlevel = :silent
  end

  def self.is_normal?
    @@runlevel == :normal
  end
end
