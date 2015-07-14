# A Ruby Component Value Matcher
# Copyright (c) 2015, Colin Shaw
# Distributed under the terms of the MIT License

require './src/component_match.rb'
		  
ComponentMatch.new([1.1,
                    1.01,
                    2.2,
                    2.21,
                    3])
              .match(2,'percent')
              .report
		
