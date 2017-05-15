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
require 'tempfile'
require 'xmp2assert/spawn'

class TC009_Spawn < Test::Unit::TestCase
  Program = <<-'end;'
    rx = IO.for_fd ARGV.shift.to_i, 'rb'
    tx = IO.for_fd ARGV.shift.to_i, 'wb'
    begin
      while a = IO.select([STDIN, rx]) do
        rs, = *a
        rs.each do |i|
          j = i.readpartial 4096
          case i
          when STDIN then
            tx.printf "STDIN: %s", j
          when rx then
            tx.printf "rx: %s", j
          end
          tx.flush
        end
      end
    rescue IOError
      # OK, end of input
      Process.exit true
    end
  end;

  setup do
    @program = Tempfile.create ''
    @program.write Program
    @program.flush
  end

  teardown do
    @program.close
    File.unlink @program.to_path
  end

  test "#initialize" do
    XMP2Assert::Spawn.new @program do |p, i, o, e, r, t|
      assert_kind_of(Integer, p)
      assert_kind_of(IO, i)
      assert_kind_of(IO, o)
      assert_kind_of(IO, e)
      assert_kind_of(IO, r)
      assert_kind_of(IO, t)

      i.puts "foo"
      i.flush
      assert_equal("STDIN: foo\n", t.gets)
      r.puts "bar"
      r.flush
      assert_equal("rx: bar\n", t.gets)
    end
  end
end
