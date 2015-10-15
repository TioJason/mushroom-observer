# encoding: utf-8

# Name Change Email

class QueuedEmail::NameChange < QueuedEmail
  def name
    get_object(:name, ::Name)
  end

  def description; get_object(:description, ::NameDescription,
                              :allow_nil); end

  def old_name_version
    get_integer(:old_name_version)
  end

  def new_name_version
    get_integer(:new_name_version)
  end

  def old_description_version
    get_integer(:old_description_version)
  end

  def new_description_version
    get_integer(:new_description_version)
  end

  def review_status
    get_string(:review_status).to_sym
  end

  def name_change
    ObjectChange.new(name, old_name_version, new_name_version)
  end

  def desc_change
    ObjectChange.new(description, old_description_version, new_description_version)
  end

  def self.create_email(sender, recipient, name, desc, review_status_changed, d = false)
    result = create(sender, recipient)
    fail "Missing name or description!" if !name && !desc
    if name
      result.add_integer(:name, name.id)
      result.add_integer(:new_name_version, name.version)
      old_version = (name.changed? || d) ? name.version - 1 : name.version
      result.add_integer(:old_name_version, old_version)
    else
      name = desc.name
      result.add_integer(:name, name.id)
      result.add_integer(:new_name_version, name.version)
      result.add_integer(:old_name_version, name.version)
    end
    if desc
      result.add_integer(:description, desc.id)
      result.add_integer(:new_description_version, desc.version)
      old_version = (desc.changed? || d) ? desc.version - 1 : desc.version
      result.add_integer(:old_description_version, old_version)
      result.add_string(:review_status, review_status_changed ? desc.review_status : :no_change)
    else
      result.add_integer(:description, 0)
      result.add_integer(:new_description_version, 0)
      result.add_integer(:old_description_version, 0)
      result.add_string(:review_status, :no_change)
    end
    result.finish
    result
  end

  def deliver_email
    # Make sure name wasn't deleted or merged since email was queued.
    NameChangeEmail.build(self).deliver if name
  end
end
