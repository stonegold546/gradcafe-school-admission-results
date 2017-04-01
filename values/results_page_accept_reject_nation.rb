# Object to display slim results
class ResultsPageAcceptRejectNation
  def initialize(a_r_nation)
    @a_r_nation = a_r_nation
    @a_r_nation_visual = Hash.new { |hash, key| hash[key] = {} }
    @q_array = [[], []]
    @v_array = [[], []]
    @gpa_array = [[], []]
    @awa_array = [[], []]
  end

  def call
    go_through_a_r_mean_box
    go_through_a_r_delete_nulls
    go_through_case
    delete_gre_subject
    [@q_array, @v_array, @gpa_array, @awa_array, @a_r_nation_visual]
  end

  def go_through_a_r_mean_box
    @a_r_nation.each_key do |key|
      @a_r_nation[key].each_key do |stat|
        @a_r_nation_visual[key]["#{stat}_mean"] = @a_r_nation[key][stat].mean
        @a_r_nation_visual[key]["#{stat}_box"] =
          generate_boxplot_array(@a_r_nation[key][stat])
      end
    end
  end

  def go_through_a_r_delete_nulls
    @a_r_nation.each_key do |key|
      @a_r_nation[key].each_key do |stat|
        @a_r_nation_visual[key]["#{stat}_mean"] ||= 0
        @a_r_nation_visual[key]["#{stat}_mean"] =
          if ['', 'NaN'].include? @a_r_nation_visual[key]["#{stat}_mean"].to_s
            0
          else @a_r_nation_visual[key]["#{stat}_mean"].to_f.round 2
          end
      end
    end
  end

  def generate_boxplot_array(arr)
    result = [arr.descriptive_statistics[:min], arr.percentile(25), arr.median,
              arr.percentile(75), arr.descriptive_statistics[:max]]
    result = [0, 0, 0, 0, 0] if result.any? { |e| e.to_s == 'NaN' || e.nil? }
    result = result.map { |e| e.to_f.round 2 }
    result
  end

  def go_through_case
    @a_r_nation.each_key do |key|
      @a_r_nation[key].each_key do |stat|
        if key.to_s.include? 'accept'
          accept_reject_case_quant_verbal(key, stat, 0)
          accept_reject_case_awa_gpa(key, stat, 0)
        elsif key.to_s.include? 'reject'
          accept_reject_case_quant_verbal(key, stat, 1)
          accept_reject_case_awa_gpa(key, stat, 1)
        end; end; end
  end

  def accept_reject_case_quant_verbal(key, stat, zero_one)
    case stat.to_s
    when 'gre_quant' then @q_array[zero_one] <<
      [last_letter_upcase(key), @a_r_nation_visual[key]["#{stat}_mean"]]
    when 'gre_verbal' then @v_array[zero_one] <<
      [last_letter_upcase(key), @a_r_nation_visual[key]["#{stat}_mean"]]
    end
  end

  def accept_reject_case_awa_gpa(key, stat, zero_one)
    case stat.to_s
    when 'undergraduate_gpa' then @gpa_array[zero_one] <<
      [last_letter_upcase(key), @a_r_nation_visual[key]["#{stat}_mean"]]
    when 'gre_awa' then @awa_array[zero_one] <<
      [last_letter_upcase(key), @a_r_nation_visual[key]["#{stat}_mean"]]
    end
  end

  def last_letter_upcase(key)
    key.to_s[-1].upcase
  end

  def delete_gre_subject
    @a_r_nation_visual.each_key do |key|
      @a_r_nation_visual[key].each_key do |stat|
        @a_r_nation_visual[key].delete(stat) if
          %w(gre_subject_mean gre_subject_box).include? stat
      end; end
  end
end
