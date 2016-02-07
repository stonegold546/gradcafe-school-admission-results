require 'json'
require 'nokogiri'
require 'zlib'
require 'base64'

PAGE_INFO_CLASS = '.pagination'
PAGE_NUMBER_POSITION = 4

# Worker to trouble gradcafe
class GradCafeWorker
  def initialize(params, url)
    @url = url
    @channel = params['channel']
    @search_term = params['search_term']
    @time_period = params['time_period']
  end

  def call(other_pages = [])
    # TODO: This is too long and complicated. BAD!
    page_one = first_page
    number_of_pages = calculate_number_of_pages(page_one)
    if number_of_pages == 0
      publish([0, 0, ''].to_json)
      return 'No results for your query'
    elsif number_of_pages > 1
      other_pages = go_through_other_pages(number_of_pages)
    else
      publish([1, 1, zlib_base64([page_one].to_s)].to_json)
      return
    end
    result = zlib_base64(([page_one] + other_pages).to_s)
    publish([number_of_pages, number_of_pages, result].to_json)
  end

  def zlib_base64(some_string)
    compressed_string = Zlib::Deflate.deflate(some_string)
    # puts some_string.size
    # puts compressed_string.size
    encoded_string = Base64.urlsafe_encode64 compressed_string
    # puts encoded_string.size
    encoded_string
  end

  def first_page
    page_number = 1
    SearchGradCafe.new(@search_term, @time_period, page_number).call
  end

  def calculate_number_of_pages(page_one)
    doc = Nokogiri::HTML(page_one)
    return 0 if doc.text.include?('Sorry, there are no results for')
    length = doc.css(PAGE_INFO_CLASS).text.split[PAGE_NUMBER_POSITION].to_i
    [length, 20].min
  end

  def go_through_other_pages(number_of_pages)
    (2..number_of_pages).to_a.map do |page_number|
      sleep 02
      result = SearchGradCafe.new(@search_term, @time_period, page_number).call
      unless page_number == number_of_pages
        publish([page_number, number_of_pages, ''].to_json)
      end
      result
    end
  end

  def publish(message)
    HTTParty.post(
      "#{@url}/faye",
      headers: { 'Content-Type' => 'application/json' },
      body: {
        channel: "/#{@channel}",
        data: message
      }.to_json
    )
  end
end
