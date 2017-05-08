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
require 'xmp2assert/parser'

class TC009_Parser < Test::Unit::TestCase
  test "error" do
    # We are not going to test ruby's pitfall-ish syntax errors here.  That's a
    # ripper's job.  We check to see if OUR class raises exception for them.
    assert_raise SyntaxError, '[ruby-core:74988]' do
      XMP2Assert::Parser.new ":~$"
    end
  end

  sub_test_case "#tokenize" do
    # Also we do not test corner cases of ruby's syntax. That's up to ripper.
    data({
      "xmp1"    => ["# => 1", [:'=>']],
      "xmp2"    => ["# >> 1", [:>>]],
      "not xmp" => ["# foo",  [:comment]],
      "number"  => ["1",      [:int]],
      "stmts"   => ["1; 1",   [:int, :semicolon, :sp, :int]],
      "nl"      => ["1\n1",   [:int, :nl, :int]],
      "str"     => ["'1'",    [:tstring_beg, :tstring_content, :tstring_end]],
    })

    test "#tokenize" do |(input, expected)|
      p = XMP2Assert::Parser.new input
      actual = p.tokens.map(&:to_sym)
      assert_equal expected, actual
    end
  end

  sub_test_case "#sexp" do
    # Also we do not test corner cases of ruby's syntax. That's up to ripper.
    data({
      "xmp"    => ["# => 1", [:program, [:stmts, [:void_stmt]]]],
      "number" => ["1; 1",   [:program, [:stmts, :int, :int]]],
      "str"    => ["'1'",    [:program,
                              [:stmts,
                               [:string_literal,
                                [:string_content,
                                 :tstring_content]]]]],
    })

    test "#sexp" do |(input, expected)|
      p = XMP2Assert::Parser.new input
      actual = recursive_map_to_sym p.sexp
      assert_equal expected, actual
    end

    private

    def recursive_map_to_sym ary
      case ary when Array then
        ary.map {|i| recursive_map_to_sym i }
      else
        ary.to_sym
      end
    end
  end
end
