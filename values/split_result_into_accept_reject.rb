# Object to create visualizable data forms
class SplitResultIntoAcceptReject
  def initialize(result)
    @result = result
    @accepted = { undergraduate_gpa: [], gre_quant: [], gre_verbal: [],
                  gre_awa: [], gre_subject: [] }
    @rejected = { undergraduate_gpa: [], gre_quant: [], gre_verbal: [],
                  gre_awa: [], gre_subject: [] }
  end

  def call
    @result.each_value do |data|
      data.each do |details|
        if details['decision'] == 'Accepted'
          work_on_item(details, @accepted)
        elsif details['decision'] == 'Rejected'
          work_on_item(details, @rejected)
        end; end; end
    [@accepted, @rejected]
  end

  def work_on_item(details, global_item)
    global_item.each_key do |key|
      item = details[key.to_s]
      global_item[key] << item unless item.include? 'n/a'
      global_item[key] -= ['', nil, '0.00', '0']
    end
  end
end
