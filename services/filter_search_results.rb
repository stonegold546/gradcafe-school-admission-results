# Service object to filter grad cafe search results
class SearchGradCafe
  def initialize(search_results, masters_phd, season, how_long)
    @search_results = search_results
    @masters_phd = masters_phd
    @season = season
    @how_long = how_long
  end
end
