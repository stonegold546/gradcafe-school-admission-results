require 'json'
require 'nokogiri'

require_relative '../services/search_grad_cafe'

PAGE_INFO_CLASS = '.pagination'
PAGE_NUMBER_POSITION = 4

# Worker to trouble gradcafe
class GradCafeWorker
  def initialize(channel, search_term, time_period)
    @channel = channel
    @search_term = search_term
    @time_period = time_period
  end

  def call(other_pages = [])
    page_one = first_page
    number_of_pages = calculate_number_of_pages(page_one)
    return 'No results for your query' if number_of_pages == 0
    other_pages = go_through_other_pages(number_of_pages) if number_of_pages > 1
    [page_one] + other_pages
  end

  def first_page
    page_number = 1
    SearchGradCafe.new(@search_term, @time_period, page_number).call
  end

  def calculate_number_of_pages(page_one)
    doc = Nokogiri::HTML(page_one)
    return 0 if doc.text.include?('Sorry, there are no results for')
    doc.css(PAGE_INFO_CLASS).text.split[PAGE_NUMBER_POSITION].to_i
  end

  def go_through_other_pages(number_of_pages)
    (2..number_of_pages).to_a.map do |page_number|
      sleep 02
      result = SearchGradCafe.new(@search_term, @time_period, page_number).call
      # publish "Searched #{page_number} of #{number_of_pages} pages"
      result
    end
  end

  def publish(message)
    HTTParty.post(
      'http://localhost:9292/faye',
      headers: { 'Content-Type' => 'application/json' },
      body: {
        channel: "/#{@channel}",
        data: "#{message}\nGradCafe is a free service so waiting"\
              ' two seconds between requests'
      }.to_json
    )
  end
end
