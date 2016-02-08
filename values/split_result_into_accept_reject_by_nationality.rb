# require 'ostruct'

# HASH = { undergraduate_gpa: [], gre_quant: [], gre_verbal: [],
#          gre_awa: [], gre_subject: [] }

# Value object for data format
class RequiredData
  # NOTE: Only because I couldn't get OpenStruct to work
  def required_data
    { undergraduate_gpa: [], gre_quant: [], gre_verbal: [],
      gre_awa: [], gre_subject: [] }
  end
end

# Object to create visualizable data forms
class SplitResultIntoAcceptRejectNation
  def initialize(result)
    @result = result
    # ap @result
    @global_item = 6.times.collect { RequiredData.new.required_data }
  end

  def call
    @result.each_value do |data|
      data.each do |details|
        if details['decision'] == 'Accepted'
          accept_case(details)
        elsif details['decision'] == 'Rejected'
          reject_case(details)
        end; end; end
    @global_item
  end

  def accept_case(details)
    case details['key']
    when 'A' then work_on_item(details, @global_item[0])
    when 'U' then work_on_item(details, @global_item[2])
    when 'I' then work_on_item(details, @global_item[4])
    end
  end

  def reject_case(details)
    case details['key']
    when 'A' then work_on_item(details, @global_item[1])
    when 'U' then work_on_item(details, @global_item[3])
    when 'I' then work_on_item(details, @global_item[5])
    end
  end

  def work_on_item(details, global_item)
    global_item.each_key do |key|
      item = details[key.to_s]
      global_item[key] << item unless item.include? 'n/a'
      global_item[key] -= ['', nil, '0.00', '0']
    end
  end
end
