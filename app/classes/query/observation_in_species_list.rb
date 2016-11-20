class Query::ObservationInSpeciesList < Query::ObservationBase
  def parameter_declarations
    super.merge(
      species_list: SpeciesList
    )
  end

  def initialize_flavor
    species_list = find_cached_parameter_instance(SpeciesList, :species_list)
    title_args[:species_list] = species_list.format_name
    add_join(:observations_species_lists)
    self.where << "observations_species_lists.species_list_id = '#{species_list.id}'"
    super
  end

  def default_order
    "name"
  end
end
