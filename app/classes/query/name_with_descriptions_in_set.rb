class Query::NameWithDescriptionsInSet < Query::NameBase
  include Query::Initializers::InSet

  def parameter_declarations
    super.merge(
      ids:        [NameDescription],
      old_title?: :string,
      old_by?:    :string
    )
  end

  def initialize_flavor
    initialize_in_set_flavor("name_descriptions")
    add_join(:name_descriptions)
    super
  end
end
