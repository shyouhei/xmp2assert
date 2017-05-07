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
require 'xmp2assert/quasifile'
require 'stringio'
require 'tempfile'
require 'pathname'
require 'uri'
require 'socket'

class TC001_Quasifile < Test::Unit::TestCase

  sub_test_case ".new" do
    data do
      prepare
      next {
        "string only"      => [["foo"           ], ['foo',  '(eval)',     1]],
        "string with file" => [["foo",  "bar"   ], ['foo',  'bar',        1]],
        "string with line" => [["foo",  nil,   2], ['foo',  '(eval)',     2]],
        "string with both" => [["foo",  "bar", 2], ['foo',  'bar',        2]],
        "file only"        => [[@@f[0]          ], ['file0', @@f[0].path, 1]],
        "file with file"   => [[@@f[1], "foo"   ], ['file1', 'foo',       1]],
        "file with line"   => [[@@f[2], nil,   2], ['file2', @@f[2].path, 2]],
        "file with both"   => [[@@f[3], "foo", 2], ['file3', 'foo',       2]],
        "path only"        => [[@@p             ], ['file0', @@p.to_s,    1]],
        "path with file"   => [[@@p,    "foo"   ], ['file0', 'foo',       1]],
        "path with line"   => [[@@p,    nil,   2], ['file0', @@p.to_s,    2]],
        "path with both"   => [[@@p,    "foo", 2], ['file0', 'foo',       2]],
        "pipe only"        => [[@@i[0]          ], ['pipe0', '(eval)',    1]],
        "pipe with file"   => [[@@i[1], "foo"   ], ['pipe1', 'foo',       1]],
        "pipe with line"   => [[@@i[2], nil,   2], ['pipe2', '(eval)',    2]],
        "pipe with both"   => [[@@i[3], "foo", 2], ['pipe3', 'foo',       2]],
        "sio only"         => [[@@s[0]          ], ['sio0',  '(eval)',    1]],
        "sio with file"    => [[@@s[1], "foo"   ], ['sio1',  'foo',       1]],
        "sio with line"    => [[@@s[2], nil,   2], ['sio2',  '(eval)',    2]],
        "sio with both"    => [[@@s[3], "foo", 2], ['sio3',  'foo',       2]],
      }
    end

    test "instantiate" do |(argv, (c, f, l))|
      subject = nil
      assert_nothing_raised { subject = XMP2Assert::Quasifile.new(*argv) }
      assert_instance_of XMP2Assert::Quasifile, subject
      assert_equal f, subject.__FILE__
      assert_equal l, subject.__LINE__
      assert_equal c, subject.read
    end

    test "file not open for read" do
      Tempfile.create '' do |f|
        fails_with IOError do
          f.tap do |ff|
            ff.reopen(f.path, 'wb')
          end
        end
      end
    end

    test "file already closed" do
      Tempfile.create '' do |f|
        fails_with IOError do
          f.tap(&:close)
        end
      end
    end

    test "nonexistent path" do
      fails_with SystemCallError do
        f = Tempfile.create ''
        File.unlink f
        Pathname.new f
      end
    end

    test "path is a directory" do
      Dir.mktmpdir do |d|
        fails_with SystemCallError do
          Pathname.new d
        end
      end
    end

    test "URI not understandable" do
      fails_with TypeError do
        URI.parse 'data:text/plain;charset=utf-8;#!/usr/bin/ruby'
      end
    end

    test "URI not openable" do
      fails_with OpenURI::HTTPError do
        URI.parse 'https://httpbin.org/status/404'
      end
    end

    test "DNS resolution failure" do
      fails_with SocketError do
        URI.parse 'https://see.RFC6761.about.this.domain.invalid'
      end
    end

    private

    def fails_with err
      assert_raise_kind_of err do
        XMP2Assert::Quasifile.new yield
      end
    end

    def self.prepare
      @@f = Array.new(4) do |i|
        f = Tempfile.create ''
        f.printf 'file%d', i
        f.flush
        f.rewind
        f
      end
      @@p = Pathname.new(@@f[0].path)
      @@i = Array.new(4) do |i|
        r, w = IO.pipe
        w.printf 'pipe%d', i
        w.close
        r
      end
      @@s = Array.new(4) do |i|
        f = StringIO.new(String.new)
        f.printf 'sio%d', i
        f.rewind
        f
      end
    end

    def self.shutdown
      @@f.each do |f|
        File.unlink(f)
        f.close
      end
    end
  end
end
