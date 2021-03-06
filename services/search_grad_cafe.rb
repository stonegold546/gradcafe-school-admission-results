require 'open-uri'

GRADCAFE = 'http://thegradcafe.com/survey/index.php?q'.freeze
TIME = 't'.freeze
PAGES = 'o=&pp=250&p'.freeze

# Service object to visit grad cafe
class SearchGradCafe
  def initialize(search_term, time_period, page_number)
    @search_term = URI.escape search_term
    @time_period = time_period
    @page_number = page_number
  end

  def call
    text = open("#{GRADCAFE}=#{@search_term}&#{TIME}=#{@time_period}&"\
         "#{PAGES}=#{@page_number}").read
    text.scan(/[[:print:]]/).join
  end
end
