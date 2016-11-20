class Query::HerbariumPatternSearch < Query::HerbariumBase
  include Query::Initializers::PatternSearch

  def parameter_declarations
    super.merge(
      pattern: :string
    )
  end

  def initialize_flavor
    search = google_parse_pattern
    add_search_conditions(search,
      "herbaria.name",
      "COALESCE(herbaria.description,'')",
      "COALESCE(herbaria.mailing_address,'')"
    )
    super
  end
end
