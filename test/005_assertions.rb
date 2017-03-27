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

class TC004_Assertions < Test::Unit::TestCase
  include XMP2Assert::Assertions

  sub_test_case "#assert_xmp" do
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
      assert_xmp expected, actual
    end

    test "assertion failure" do
      assert_raise Test::Unit::AssertionFailedError do
        assert_xmp '2', 1
      end
    end

    test "assertion failure's message" do
      assert_raise_message(/foobar/) do
        assert_xmp '2', 1, 'foobar'
      end
    end
  end

  sub_test_case "#assert_capture2e" do
    test "assertion success" do
      q = XMP2Assert::Quasifile.new 'puts "foo"'
      assert_capture2e "foo\n", q
    end

    test "assertion failure" do
      assert_raise Test::Unit::AssertionFailedError do
        q = XMP2Assert::Quasifile.new 'puts "foo"'
        assert_capture2e "bar\n", q
      end
    end

    test "unicode" do
      q = XMP2Assert::Quasifile.new 'puts "\u674E\u5FB4"'
      assert_capture2e "\u674E\u5FB4\n", q
    end

    test "non-unicode" do
      source   = "puts \"\u674E\u5FB4\"".encode Encoding::Windows_31J
      expected = "\u674E\u5FB4\n".encode Encoding::Windows_31J
      qfile    = XMP2Assert::Quasifile.new source
      assert_capture2e expected, qfile
    end

    test "stdin" do
      q = XMP2Assert::Quasifile.new 'puts ARGF.read'
      assert_capture2e "foo\n", q, stdin_data: 'foo'
    end
  end
end
