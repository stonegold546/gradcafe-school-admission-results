require 'descriptive_statistics'

TIMER = {
  'n' => 'today only', 't' => 'past two days', 'w' => 'past week',
  'm' => 'past month', 'a' => 'all time'
}.freeze

# Object to create all the necessary results for the results page
class ResultsPage
  def initialize(accept_reject, time_period)
    @accepted = accept_reject[0]
    @rejected = accept_reject[1]
    @time_period = TIMER[time_period]
  end

  def call
    accepted_column = column_data(@accepted)
    accepted_column = column_data_default(accepted_column)
    rejected_column = column_data(@rejected)
    rejected_column = column_data_default(rejected_column)
    accepted_box = box_data(@accepted)
    rejected_box = box_data(@rejected)
    [
      accepted_column, rejected_column,
      accepted_box, rejected_box, @time_period
    ]
  end

  def generate_boxplot_array(arr)
    result = [arr.descriptive_statistics[:min], arr.percentile(25), arr.median,
              arr.percentile(75), arr.descriptive_statistics[:max]]
    result = [0, 0, 0, 0, 0] if result.any? { |e| e.to_s == 'NaN' || e.nil? }
    result = result.map { |e| e.to_f.round 2 }
    result
  end

  def column_data(global_item, global_item_gre = {}, global_item_gpa_awa = {})
    global_item.each_key do |key|
      if [:gre_quant, :gre_verbal].include? key
        global_item_gre[key] = global_item[key].mean
      elsif [:gre_awa, :undergraduate_gpa].include? key
        global_item_gpa_awa[key] = global_item[key].mean
      end
    end
    [global_item_gre, global_item_gpa_awa]
  end

  def column_data_default(gre_gpa_awa)
    gre_gpa_awa.each do |item|
      item.each_key do |key|
        item[key] ||= 0
        item[key] = 0 if ['', 'NaN'].include? item[key].to_s
        item[key] = item[key].to_f.round 2
      end
    end
    gre_gpa_awa
  end

  def box_data(global_item, global_item_gre_box = {},
               global_item_gpa_awa_box = {})
    global_item.each_key do |key|
      if [:gre_quant, :gre_verbal].include? key
        global_item_gre_box[key] = generate_boxplot_array(global_item[key])
      elsif [:gre_awa, :undergraduate_gpa].include? key
        global_item_gpa_awa_box[key] = generate_boxplot_array(global_item[key])
      end
    end
    [global_item_gre_box, global_item_gpa_awa_box]
  end
end
