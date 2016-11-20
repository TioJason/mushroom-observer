class Query::NameByEditor < Query::NameBase
  def parameter_declarations
    super.merge(
      user: User
    )
  end

  def initialize_flavor
    user = find_cached_parameter_instance(User, :user)
    title_args[:user] = user.legal_name
    version_table = :names_versions
    add_join(version_table)
    self.where << "#{version_table}.user_id = '#{user.id}'"
    self.where << "names.user_id != '#{user.id}'"
    super
  end
end
