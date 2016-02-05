require 'sinatra/base'
require 'sinatra/config_file'
require 'httparty'
require 'slim'
require 'slim/include'
require 'json'
require 'tilt/kramdown'
require 'securerandom'
require 'ap'
require 'chartkick'
require 'descriptive_statistics'

# Sinatra App to Visualize Grad Cafe Survey data
class GradCafeVisualizationApp < Sinatra::Base
  enable :logging
  register Sinatra::ConfigFile
  config_file '../config/config.yml'

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  get '/' do
    slim :index
  end

  get '/search/?' do
    url = 'https://grad-cafe-visualizations.herokuapp.com'
    search_results = GradCafeWorker.new(params, url).call
    halt 404 if search_results == 'No results for your query'
    FilterSearchResults.new(
      search_results, params['masters_phd'], params['search_season']
    ).call.to_json
  end

  post '/result/?' do
    result = JSON.parse(params['result'])
    result = SplitResultIntoAcceptReject.new(result).call
    result = ConvertOldGreToNewGre.new(result).call
    accepted = result[0]
    rejected = result[1]
    slim :result, locals: {
      accepted: accepted, rejected: rejected,
      search_term: params['search_term'], time_period: params['time_period'],
      masters_phd: params['masters_phd'], search_season: params['search_season']
    }
  end
end
