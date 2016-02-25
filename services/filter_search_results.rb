require 'nokogiri'

TABLE_ROWS = '//table/tbody/tr'
TABLE_DATA = 'td'
GEM_EXT_DATA = '.extinfo'
REMOVE_GRE = 'GRE'

# Service object to filter grad cafe search results
class FilterSearchResults
  def initialize(search_results, masters_phd, search_season)
    @search_results = search_results
    @masters_phd = masters_phd
    @search_season = search_season
  end

  def call(results = {})
    @search_results.each do |page|
      page = Nokogiri::HTML(page)
      page.xpath(TABLE_ROWS).each do |row|
        row_info = row.search(TABLE_DATA)
        filter_info = row_info[1].text.split
        season = filter_info[-1]
        degree = filter_info[-2]
        results = create_data(results, row_info, season, degree)
      end; end
    results
  end

  def create_data(results, row_info, season, degree)
    return results unless season.include? @search_season
    return results unless degree.include? @masters_phd
    institution = row_info[0].text
    results[institution] ||= []
    gem_data = row_info[2].css(GEM_EXT_DATA).map(&:text)[0]
    results[institution] <<
      work_the_gem_span(gem_data).merge(decision_nationality(row_info))
    results
  end

  def decision_nationality(row_info)
    status = row_info[2].text.split[0]
    { decision: status, key: row_info[3].text, date: row_info[4].text }
  end

  def work_the_gem_span(gem_data)
    if gem_data.nil?
      { undergraduate_gpa: '', gre_quant: '', gre_verbal: '',
        gre_awa: '', gre_subject: '' }
    else
      words = gem_data.split
      gre = words[5].chomp(REMOVE_GRE).split('/')
      { undergraduate_gpa: words[2].chomp(REMOVE_GRE), gre_quant: gre[1],
        gre_verbal: gre[0], gre_awa: gre[2], gre_subject: words[7] }
    end
  end
end
