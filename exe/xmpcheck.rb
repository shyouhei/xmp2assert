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

abort "usage: #$0 FILES..." if ARGV.empty?

require 'test/unit/autorunner'
require 'pathname'
require 'xmp2assert'

class TC_Main < Test::Unit::TestCase
  include XMP2Assert::Assertions

  def self.expandfs argv
    files = []
    argv.each do |i|
      p = Pathname.new i
      if p.directory? then
        files += expandfs p.children # recur
      else
        files << p
      end
    end

    files.map! do |i|
      XMP2Assert::Quasifile.new i
    end

    return files
  end
  private_class_method :expandfs

  a = expandfs ARGV
  p a
  a.each do |f|
    klass = XMP2Assert::Classifier.classify f

    if klass.empty? then
      test f.__FILE__ do
        pend "no tests for #{f.__FILE__}"
      end
    else
      test f.__FILE__ do
        t, o = XMP2Assert::Converter.convert f
        if klass.include? :'=>' then
          t.eval binding
        end
        if klass.include? :'>>' then
          assert_capture2e o, f
        end
      end
    end
  end
end
