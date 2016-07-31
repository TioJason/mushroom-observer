class Query::SpeciesListByRssLog < Query::SpeciesList
  def initialize
    add_join(:rss_logs)
    params[:by] ||= "rss_log"
    super
  end
end
