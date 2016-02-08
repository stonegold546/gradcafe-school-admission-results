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
    # url = 'https://grad-cafe-visualizations.herokuapp.com'
    url = 'http://localhost:9292'
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
    accepted = accept_reject[0]
    rejected = accept_reject[1]
    a_r_nation = {
      accepted_a: a_r_nation[0], accepted_u: a_r_nation[2],
      accepted_i: a_r_nation[4], rejected_a: a_r_nation[1],
      rejected_u: a_r_nation[3], rejected_i: a_r_nation[5]
    }
    # ap accept_reject_nation
    slim :result, locals: {
      accepted: accepted, rejected: rejected, a_r_nation: a_r_nation,
      # accepted_a: accepted_a, accepted_i: accepted_i, accepted_u: accepted_u,
      # rejected_a: rejected_a, rejected_i: rejected_i, rejected_u: rejected_u,
      search_term: params['search_term'], time_period: params['time_period'],
      masters_phd: params['masters_phd'], search_season: params['search_season']
    }
  end
end
