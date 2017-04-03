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
require 'xmp2assert'

class TC003_Classifier < Test::Unit::TestCase
  data({
    "syntax error" => ['"#{unmatched paren', []],
    "no comment"   => ['true',               []],
    "no mark"      => ['# comment',          []],
    "marked 1"     => ['0x1 # => 1',         [:'=>']],
    "marked 2"     => ['puts("x") # >> x',   [:'>>']],
    "marked 3"     => ['puts("y") # ~> y',   [:'>>']],
    "multi mark"   => ["# => 1\n# => 2",     [:'=>']],
    "combined"     => ["# => 1\n# >> 2",     [:'=>', :'>>']],
  })

  test "#classify" do |(str, ary)|
    assert_equal ary, XMP2Assert::Classifier.classify(str)
  end
end
