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
require 'rbconfig'
require 'xmp2assert/renderer'
require 'xmp2assert/quasifile'

class TC010_Renderer < Test::Unit::TestCase
  setup do
    @files = []
    @src   = XMP2Assert::Quasifile.new <<-'end;', 'foo', 32768
      puts "foo"
    end;
  end

  teardown do
    @files.each do |f|
      File.unlink f.to_path
    end
  end

  test "with block" do
    obj = Object.new
    result = XMP2Assert::Renderer.render @src do |f|
      assert_kind_of(File, f)
      assert(system("#{RbConfig.ruby} -wc #{f.to_path}", out: IO::NULL))
      next obj
    end
    assert_same(obj, result)
  end

  test "without block" do
    f = XMP2Assert::Renderer.render @src
    @files << f
    assert_kind_of(File, f)
    assert(system("#{RbConfig.ruby} -wc #{f.to_path}", out: IO::NULL))
  end
end
