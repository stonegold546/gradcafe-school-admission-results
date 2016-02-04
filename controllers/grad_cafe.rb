require 'sinatra/base'
require 'httparty'
require 'slim'
require 'slim/include'
require 'json'
require 'tilt/kramdown'
require 'securerandom'
require 'ap'

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
    # TODO: Break this shit up
    result = JSON.parse(params['result'])
    accepted = { undergraduate_gpa: [], gre_quant: [], gre_verbal: [],
                 gre_awa: [], gre_subject: [] }
    rejected = { undergraduate_gpa: [], gre_quant: [], gre_verbal: [],
                 gre_awa: [], gre_subject: [] }
    result.each do |_institution, data|
      data.each do |details|
        if details['decision'] == 'Accepted'
          accepted[:undergraduate_gpa] << details['undergraduate_gpa'] unless
            details['undergraduate_gpa'].include? 'n/a'
          accepted[:gre_quant] << details['gre_quant'] unless
            details['gre_quant'].include? 'n/a'
          accepted[:gre_verbal] << details['gre_verbal'] unless
            details['gre_verbal'].include? 'n/a'
          accepted[:gre_awa] << details['gre_awa'] unless
            details['gre_awa'].include? 'n/a'
          accepted[:gre_subject] << details['gre_subject'] unless
            details['gre_subject'].include? 'n/a'
        elsif details['decision'] == 'Rejected'
          rejected[:undergraduate_gpa] << details['undergraduate_gpa'] unless
            details['undergraduate_gpa'].include? 'n/a'
          rejected[:gre_quant] << details['gre_quant'] unless
            details['gre_quant'].include? 'n/a'
          rejected[:gre_verbal] << details['gre_verbal'] unless
            details['gre_verbal'].include? 'n/a'
          rejected[:gre_awa] << details['gre_awa'] unless
            details['gre_awa'].include? 'n/a'
          rejected[:gre_subject] << details['gre_subject'] unless
            details['gre_subject'].include? 'n/a'
        end
      end
    end

    accepted[:undergraduate_gpa] -= ['', nil, '0.00', '0']
    accepted[:gre_quant] -= ['', nil, '0.00', '0']
    accepted[:gre_verbal] -= ['', nil, '0.00', '0']
    accepted[:gre_awa] -= ['', nil, '0.00', '0']
    accepted[:gre_subject] -= ['', nil, '0.00', '0']
    rejected[:undergraduate_gpa] -= ['', nil, '0.00', '0']
    rejected[:gre_quant] -= ['', nil, '0.00', '0']
    rejected[:gre_verbal] -= ['', nil, '0.00', '0']
    rejected[:gre_awa] -= ['', nil, '0.00', '0']
    rejected[:gre_subject] -= ['', nil, '0.00', '0']

    slim :result, locals: { accepted: accepted, rejected: rejected }
  end

  # get '/result/?' do
  # end
end
