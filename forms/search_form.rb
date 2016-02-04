require 'virtus'
require 'active_model'

TIME_PERIOD = %w(n t w m a)
DEGREE = ['', 'PhD', 'Masters', 'MFA', 'MBA', 'JD', 'EdD', 'Other']
SEASON = 16.downto(13).to_a.map do |year|
  %w(F S).map { |season| "#{season}#{year}" }
end + ['']

# Form object to make sure search conforms to what is required of humanity
class SearchForm
  include Virtus.model
  include ActiveModel::Validations

  attribute :search_term, String
  attribute :time_period, String
  attribute :masters_phd, String
  attribute :search_season, String

  validates :search_term, presence: true
  validates_inclusion_of :time_period, in: TIME_PERIOD
  validates_inclusion_of :masters_phd, in: DEGREE
  validates_inclusion_of :search_season, in: SEASON

  def error_fields
    errors.messages.keys.map(&:to_s).join('; ') + ' missing/wrong format'
  end
end
