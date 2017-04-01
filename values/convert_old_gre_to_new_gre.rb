require 'yaml'

# Object to convert old GRE to new GRE
class ConvertOldGreToNewGre
  def initialize(accept_reject)
    @accept_reject = accept_reject
    @verbal = YAML.load(File.read('values/verbal.yml')).to_h
    @quant = YAML.load(File.read('values/quant.yml')).to_h
  end

  def call
    @accept_reject.each_index do |idx|
      @accept_reject[idx].each do |key, _value|
        case key
        when :undergraduate_gpa then undergraduate_gpa_work(key, idx)
        when :gre_quant then gre_quant_verbal_work(key, idx, @quant)
        when :gre_verbal then gre_quant_verbal_work(key, idx, @verbal)
        when :gre_awa then gre_awa_work(key, idx)
        when :gre_subject then gre_subject_work(key, idx)
        end; end; end
    @accept_reject
  end

  def undergraduate_gpa_work(key, idx)
    @accept_reject[idx][key] =
      @accept_reject[idx][key].map(&:to_f).select do |value|
        value if value >= 0 && value <= 4
      end
  end

  def gre_quant_verbal_work(key, idx, global_item)
    @accept_reject[idx][key] =
      @accept_reject[idx][key].map(&:to_i).map do |value|
        value = global_item[value.to_s].to_i if value > 170
        value
      end
    @accept_reject[idx][key] = @accept_reject[idx][key].select do |value|
      value if value >= 130
    end
  end

  def gre_awa_work(key, idx)
    @accept_reject[idx][key] =
      @accept_reject[idx][key].map(&:to_f).select do |value|
        value if value > 0 && value <= 6
      end
  end

  def gre_subject_work(key, idx)
  end
end
