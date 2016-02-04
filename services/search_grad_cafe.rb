require 'open-uri'

GRADCAFE = 'http://thegradcafe.com/survey/index.php?q'
TIME = 't'
PAGES = 'o=&pp=250&p'

# Service object to visit grad cafe
class SearchGradCafe
  def initialize(search_term, time_period, page_number)
    @search_term = search_term
    @time_period = time_period
    @page_number = page_number
  end

  def call
    open("#{GRADCAFE}=#{@search_term}&#{TIME}=#{@time_period}&"\
         "#{PAGES}=#{@page_number}").read
  end
end
