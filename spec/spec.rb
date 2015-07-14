# A Ruby Component Value Matcher
# Copyright (c) 2015, Colin Shaw
# Distributed under the terms of the MIT License

require 'test/unit'
require '../src/component_match.rb'

class TestComponentMatch < Test::Unit::TestCase

    def test_array_absolute
        matched = ComponentMatch.new([1.1,
                                      1.01,
                                      2.2,
                                      2.21,
                                      3])
                                .match(0.05)
                                .matched
        residual = ComponentMatch.new([1.1,
                                       1.01,
                                       2.2,
                                       2.21,
                                       3])
                                 .match(0.05)
                                 .residual
        assert_equal([[2.21, 2.2, 0.009999999999999787]],matched)
        assert_equal([1.1, 1.01, 3],residual)
    end

    def test_array_percent
        matched = ComponentMatch.new([1.1,
                                      1.01,
                                      2.2,
                                      2.21,
                                      3])
                                .match(5,'percent')
                                .matched
        residual = ComponentMatch.new([1.1,
                                       1.01,
                                       2.2,
                                       2.21,
                                       3])
                                 .match(5,'percent')
                                 .residual
        assert_equal([[2.21, 2.2, 0.45351473922901525]],matched)
        assert_equal([1.1, 1.01, 3],residual)
    end

    def test_csv_percent
        matched = ComponentMatch.new('test.csv')
                                .match(5,'percent')
                                .matched
        residual = ComponentMatch.new('test.csv')
                                 .match(5,'percent')
                                 .residual
        assert_equal([[1.0, 1.01, 0.9950248756218916], [1.5, 1.501, 0.0666444518493762]],matched)
        assert_equal([1.55, 1.7, 2.0],residual)
    end

end

