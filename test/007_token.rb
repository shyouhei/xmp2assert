#! /your/favourite/path/to/ruby
# -*- mode: ruby; coding: utf-8; indent-tabs-mode: nil; ruby-indent-level 2 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Copyright (c) 2017 Urabe, Shyouhei
#
# Permission is hereby granted, free of  charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction,  including without limitation the rights
# to use,  copy, modify,  merge, publish,  distribute, sublicense,  and/or sell
# copies  of the  Software,  and to  permit  persons to  whom  the Software  is
# furnished to do so, subject to the following conditions:
#
#         The above copyright notice and this permission notice shall be
#         included in all copies or substantial portions of the Software.
#
# THE SOFTWARE  IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY  KIND, EXPRESS OR
# IMPLIED,  INCLUDING BUT  NOT LIMITED  TO THE  WARRANTIES OF  MERCHANTABILITY,
# FITNESS FOR A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  EVENT SHALL THE
# AUTHORS  OR COPYRIGHT  HOLDERS  BE LIABLE  FOR ANY  CLAIM,  DAMAGES OR  OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require_relative 'test_helper'
require 'xmp2assert/token'

class TC007_token < Test::Unit::TestCase
  test "#compare" do
    x = XMP2Assert::Token.new nil, nil, 1
    y = XMP2Assert::Token.new nil, nil, 2
    assert_equal(true, x < y)
  end

  test "#raise" do
    x = XMP2Assert::Token.new nil, nil, ["x", 1, 2]
    assert_raise(SyntaxError) { x.raise }
    # how do we test backtrace?
  end

  test "#to_sym" do
    x = XMP2Assert::Token.new :x, nil, [nil, nil, nil]
    assert_equal(:x, x.to_sym)
  end

  test "#to_s" do
    x = XMP2Assert::Token.new nil, "x", [nil, nil, nil]
    assert_equal("x", x.to_s)
  end

  test "#__FILE__" do
    x = XMP2Assert::Token.new nil, nil, ["x", nil, nil]
    assert_equal("x", x.__FILE__)
  end

  test "#__LINE__" do
    x = XMP2Assert::Token.new nil, nil, [nil, 1, nil]
    assert_equal(1, x.__LINE__)
  end

  test "#__COLUMN__" do
    x = XMP2Assert::Token.new nil, nil, [nil, nil, 1]
    assert_equal(1, x.__COLUMN__)
  end

  unless $DEBUG
    test "#inspect" do
      x = XMP2Assert::Token.new :foo, "bar", [nil, nil, nil]
      assert_equal('(:foo "bar")', x.inspect)
    end
  end
end
