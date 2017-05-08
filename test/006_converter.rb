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
require 'xmp2assert/converter'

class TC006_Converter < Test::Unit::TestCase
  include XMP2Assert::Assertions

  test ".convert" do
    qfile = XMP2Assert::Quasifile.new <<-'end;', __FILE__, __LINE__ + 1
      # @return self
      def foo
        x = [1, 2] # => [1,
                   # =>  2]
        puts x.first
        return self
      end
      foo # >> 1
    end;
    src, out = XMP2Assert::Converter.convert qfile
    assert_match(/assert_xmp\(\"\[1,/, src.read)
    assert_equal("1\n", out)
    suppress do
      src.eval binding
    end
    assert_capture2e(out, qfile)
  end

  test "syntax error" do
    assert_raise SyntaxError do
      XMP2Assert::Converter.convert "# => 1"
    end
  end
end
