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
require 'xmp2assert/assertions'

class TC005_Assertions < Test::Unit::TestCase
  include XMP2Assert::Assertions

  sub_test_case "#assert_xmp_raw" do
    data({
      "class"   => [TrueClass, 'TrueClass'],
      "integer" => [1, '1'],
      "numeric" => [1.1, '1.1'],
      "object"  => [Object.new, '#<Object:0x007f896c9b49c8>'],
      "array"   => [[1], '[1]'],
      "hash"    => [{ 1 => 2 }, '{1=>2}'],
      "string"  => ['"foo.bar"', '"\\"foo.bar\\""'],
    })

    test "assertion success" do |(actual, expected)|
      assert_xmp_raw expected, actual.inspect
    end

    test "assertion failure" do
      assert_raise Test::Unit::AssertionFailedError do
        assert_xmp_raw '2', '1'
      end
    end

    test "assertion failure's message" do
      assert_raise_message(/foobar/) do
        assert_xmp_raw '2', '1', 'foobar'
      end
    end
  end
end
