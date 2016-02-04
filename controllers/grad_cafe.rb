require 'sinatra/base'
require 'httparty'
require 'slim'
require 'slim/include'
require 'json'
require 'tilt/kramdown'
require 'securerandom'

# Sinatra App to Visualize Grad Cafe Survey data
class GradCafeVisualizationApp < Sinatra::Base
  enable :logging

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  get '/' do
    slim :index
  end

  get '/search/?' do
    search_results = GradCafeWorker.new(params).call
    halt 404 if search_results == 'No results for your query'
    FilterSearchResults.new(
      search_results, params['masters_phd'], params['search_season']
    ).call.to_json
  end

  post '/result/?' do
    slim :result, locals: { result: req['result'] }
  end

  # get '/result/?' do
  # end
end
