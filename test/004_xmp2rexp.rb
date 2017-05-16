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
require 'xmp2assert/xmp2rexp'

class TC004_XMP2Rexp < Test::Unit::TestCase
  include XMP2Assert::XMP2Rexp

  data({
    "class"   => ['TrueClass', /\ATrueClass\n?\z/],
    "integer" => ['1', /\A1\n?\z/],
    "numeric" => ['1.0', /\A1\.0\n?\z/],
    "object"  => ['#<Object:0x007f896c9b49>', /\A\#<Object:0x[0-9a-f]+>\n?\z/],
    "array"   => ['[1]', /\A\[1\]\n?\z/],
    "hash"    => ['{1=>2}', /\A\{1=>2\}\n?\z/],
    "string"  => ['"foo.bar"', /\A"foo\.bar"\n?\z/],
    "dstr"    => ['"foo#{bar}"', /\A"foo\#\{bar\}"\n?\z/],
    "\\n #0"  => ['foo',     /\Afoo\n?\z/],
    "\\n #1"  => ["foo\n",   /\Afoo\n?\z/],
    "\\n #2"  => ["foo\n\n", /\Afoo\n{2}\z/],
    "\\n #3"  => ['foo\n',   /\Afoo\\n\n?\z/],
    "complex" => [ <<'EOF', /\A#{<<'EOF'.chomp.gsub(/(\n|\s)+/, '\s+')}\n?\z/],
#<PP:0x007fe02908fe88
 @buffer=[],
 @buffer_width=0,
 @genspace=
  #<Proc:0x007fe02908fe10@lib/ruby/2.5.0/prettyprint.rb:86 (lambda)>,
 @group_queue=
  #<PrettyPrint::GroupQueue:0x007fe02908fcf8
   @queue=
    [[#<PrettyPrint::Group:0x007fe02908fd98
       @break=false,
       @breakables=[],
       @depth=0>]]>,
 @group_stack=
  [#<PrettyPrint::Group:0x007fe02908fd98
    @break=false,
    @breakables=[],
    @depth=0>],
 @indent=0,
 @maxwidth=79,
 @newline="\n",
 @output="",
 @output_width=0>
EOF
\#<PP:0x[0-9a-f]+
 @buffer=\[\],
 @buffer_width=0,
 @genspace=
  \#<Proc:0x[0-9a-f]+@lib/ruby/2\.5\.0/prettyprint\.rb:\d+ \(lambda\)>,
 @group_queue=
  \#<PrettyPrint::GroupQueue:0x[0-9a-f]+
   @queue=
    \[\[\#<PrettyPrint::Group:0x[0-9a-f]+
       @break=false,
       @breakables=\[\],
       @depth=0>\]\]>,
 @group_stack=
  \[\#<PrettyPrint::Group:0x[0-9a-f]+
    @break=false,
    @breakables=\[\],
    @depth=0>\],
 @indent=0,
 @maxwidth=79,
 @newline="\\n",
 @output="",
 @output_width=0>
EOF
  })

  test "escape" do |(expr, expected)|
    actual = xmp2rexp expr
    assert_equal actual, expected
    assert_match actual, expr
  end
end
