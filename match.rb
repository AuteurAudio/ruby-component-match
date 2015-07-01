# A Ruby Component Value Matcher
# Copyright (c) 2015, Colin Shaw
# Distributed under the terms of the MIT License 

require 'csv'

class ComponentMatch

    def generate_diff_list(ordered_list)
        diff_list = []
        (0..ordered_list.count-2).each do |i|
            diff_list[i] = (ordered_list[i] - ordered_list[i+1]).abs  
        end
        diff_list
    end

    def select_pairs_from_diff_list(diff_list)
        pair_list = []
        i = 0
        while i < diff_list.count-1 do  
            if diff_list[i] <= diff_list[i+1] 
                pair_list[i]   = true
                pair_list[i+1] = false
                i = i + 2
            else
                pair_list[i] = false
                i = i + 1
            end
        end
        if diff_list.count > 0
            pair_list[diff_list.count-1] = true 
        end
        pair_list
    end

    def generate_pairings_with_error(ordered_list, pair_list)
        result = []
        pair_list.each.with_index do |l,i|
            if l == true
                if @diff_mode == 'absolute'
                    error = (ordered_list[i] - ordered_list[i+1]).abs
                elsif @diff_mode == 'percent'
                    error = (200 * (ordered_list[i] - ordered_list[i+1]) / (ordered_list[i] + ordered_list[i+1])).abs
                end
                result << [ordered_list[i],ordered_list[i+1],error] 
            end
        end
        result
    end

    def ordered_pairmatch(ordered_list)
        diff_list = generate_diff_list(ordered_list)
        pair_list = select_pairs_from_diff_list(diff_list)    
        results   = generate_pairings_with_error(ordered_list,pair_list)    
        results.keep_if { |x| x[2] <= @threshold }
    end

    def pairmatch(unordered_list)
        l1 = ordered_pairmatch(unordered_list.sort).sort
        l2 = ordered_pairmatch(unordered_list.sort.reverse).sort
        if l1.count > l2.count 
            l1
        else
            l2
        end
    end

    def get_residual(original_list, current_pair_list)
        temp = []
        current_pair_list.each do |v|
            temp << v[0]
            temp << v[1]
        end
        original_list - temp
    end

    def match(threshold, diff_mode='percent')
        @threshold = threshold
        @diff_mode = diff_mode
        matched    = []
        continue   = true
        while continue do
            residual  = get_residual(@original_list, matched)
            new_pairs = pairmatch(residual)
            if new_pairs.count == 0
                continue = false
            else
                new_pairs.each do |p|
                    matched << p
                end
            end    
        end
        print_report(matched,residual)
    end
    
    def print_report(matched, residual)
        percentage = sprintf("%.0f" % (200 * Float(matched.count) / Float(@original_list.count)))
        puts matched.count.to_s + ' pairs computed out of ' + @original_list.count.to_s + ' candidates (' + percentage + '% matched):'
        puts 
        matched.sort.each do |p|
            if @diff_mode == 'absolute'
                printf "   [ %.2f | %.2f ]    %.2f\n", p[0], p[1], p[2]
            elsif @diff_mode == 'percent'
                printf "   [ %.2f | %.2f ]    %.2f%\n", p[0], p[1], p[2]
            end
        end
        puts
        puts 'Unmatch values:'
        puts '   ' + residual.sort.to_s
    end

    def initialize(arg,col=0)
        if arg.is_a?String
            @original_list = []
            CSV.foreach(arg) { |row| @original_list << Float(row[col]) } 
        elsif arg.is_a?Array
            @original_list = arg
        end
    end

    private :generate_diff_list, :select_pairs_from_diff_list, :generate_pairings_with_error, :ordered_pairmatch, :get_residual, :print_report
    
end 
