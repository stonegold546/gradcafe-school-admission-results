require 'sinatra/base'
require 'httparty'
require 'slim'
require 'slim/include'
require 'json'
require 'tilt/kramdown'
require 'securerandom'
require 'ap'
require 'chartkick'
require 'descriptive_statistics'
require 'zlib'
require 'base64'

# Sinatra App to Visualize Grad Cafe Survey data
class GradCafeVisualizationApp < Sinatra::Base
  enable :logging

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  get '/' do
    slim :index
  end

  get '/search/?' do
    url = 'https://grad-cafe-visualizations.herokuapp.com'
    # url = 'http://localhost:9292'
    search_results = GradCafeWorker.new(params, url).call
    search_results == 'No results for your query' ? halt(404) : 302
  end

  post '/result/?' do
    result = Zlib::Inflate.inflate(
      Base64.urlsafe_decode64(params['result'])
    )
    result = JSON.parse result
    result = FilterSearchResults.new(
      result, params['masters_phd'], params['search_season']
    ).call
    result = JSON.parse(result.to_json)
    accept_reject = SplitResultIntoAcceptReject.new(result).call
    accept_reject = ConvertOldGreToNewGre.new(accept_reject).call
    a_r_nation = SplitResultIntoAcceptRejectNation.new(result).call
    a_r_nation = ConvertOldGreToNewGre.new(a_r_nation).call
    results_page = ResultsPage.new(accept_reject, params['time_period']).call
    accepted_gre, accepted_gpa_awa = results_page[0]
    rejected_gre, rejected_gpa_awa = results_page[1]
    accepted_gre_box, accepted_gpa_awa_box = results_page[2]
    rejected_gre_box, rejected_gpa_awa_box = results_page[3]
    timer = results_page[4]
    a_r_nation = {
      accepted_a: a_r_nation[0], accepted_u: a_r_nation[2],
      accepted_i: a_r_nation[4], rejected_a: a_r_nation[1],
      rejected_u: a_r_nation[3], rejected_i: a_r_nation[5]
    }
    results_page_a_r = ResultsPageAcceptRejectNation.new(a_r_nation).call
    q_array = results_page_a_r[0]
    v_array = results_page_a_r[1]
    gpa_array = results_page_a_r[2]
    awa_array = results_page_a_r[3]
    a_r_nation_visual = results_page_a_r[4]
    slim :result, locals: {
      accepted_gre: accepted_gre, accepted_gpa_awa_box: accepted_gpa_awa_box,
      accepted_gre_box: accepted_gre_box, rejected_gre_box: rejected_gre_box,
      accepted_gpa_awa: accepted_gpa_awa, rejected_gpa_awa: rejected_gpa_awa,
      rejected_gre: rejected_gre, rejected_gpa_awa_box: rejected_gpa_awa_box,
      a_r_nation_visual: a_r_nation_visual, q_array: q_array, v_array: v_array,
      gpa_array: gpa_array, awa_array: awa_array, time_period: timer,
      search_term: params['search_term'], masters_phd: params['masters_phd'],
      search_season: params['search_season']
    }
  end
end
