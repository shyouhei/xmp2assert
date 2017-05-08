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

class TC009_Integrated < Test::Unit::TestCase
  include XMP2Assert::Assertions

  data({
    "immediate"  => "1         # => 1",
    "binop"      => "1 + 1     # => 2",
    "semicolon1" => "3; 2      # => 2",
    "semicolon2" => "3; 2;     # => 2",
    "newline"    => "1\n       # => 1",
    "comment"    => "1 # foo\n # => 1",

    "array0"     => "[]     # => []",
    "array1"     => "[1]    # => [1]",
    "array2"     => "[1, 2] # => [1, 2]",
    "array2-nl"  => <<-'end',
      [ 1, # => 1
        2, # => 2
      ]    # => [1, 2]
    end
    "array-aref" => <<-'end',
      [ 1, # => 1
        2, # => 2
      ][0] # => 1
    end

    "hash0"     => "{}          # => {}",
    "hash1"     => "{1=>1}      # => {1=>1}",
    "hash2"     => "{1=>1,1=>1} # => {1=>1}",
    "hash-nl"   => <<-'end',
      { 1 => 1, # => 1
        1 => 2, # => 2
      }         # => {1=>2}
    end
    "hash-aref" => <<-'end',
      { 1 => 1, # => 1
        1 => 2, # => 2
      }[1]      # => 2
    end

    "string"    => '"3; 2"             # => "3; 2"',
    "dstring0"  => '"#{3; 2}"         # => "2"',
    "dstring1"  => '"#{3; "#{1; 2}"}" # => "2"',
    # we support ruby 2.2, squiggly heredoc not usable
    "heredoc1"  => <<-'end'.gsub(/^\s+/, ''),
      <<EOS # => "1\n"
      1
      EOS
    end
    "heredoc2"  => <<-'end'.gsub(/^\s+/, ''),
      <<EOS
      1
      EOS
      # => "1\n"
    end
    "heredoc_embexpr" => <<-'end'.gsub(/^      /, ''),
      <<"EOS"
        #{2; <<-"EOS"}
          1
        EOS
      EOS
      # => "    1\n\n"
    end

    "assign"  => "x    = 1       # => 1",
    "massign" => "x, y = 1, 2    # => [1, 2]",
    "lvar"    => "x    = 1; x    # => 1",
    "ivar"    => "@x   = 1; @x   # => 1",

    "if-end"     => "if true then 1 else 2 end # => 1",
    "if-mod"     => "1 if true                 # => 1",
    "ternary op" => "true ? 1 : 2              # => 1",
    "if-nl"      =>  <<-'end',
      if false then 2 # => 2
      else 1 # => 1
      end # => 1
    end
    "if-nl1"     =>  <<-'end',
      if false then # => false
        2 # => 2
      else
        1 # => 1
      end # => 1
    end

    "method"   => "def foo\n  1\nend\n foo # => 1",
    "block"    => "1.tap {|i| i + 1 }      # => 1",
    "block-nl" => "1.tap {|i|\n i + 1\n}   # => 1",
    "block-do" => "1.tap do |i|  i + 1 end # => 1",

    "&&" => <<-'end',
      "a" < "z" && "A" < "z" # => true
    end

    "capture"    => "STDOUT.puts  'foo' # >> foo",
    "capture-nl" => "STDOUT.write 'foo' # >> foo\n",
  })

  test "assert" do |expr|
    begin
      v, $-w = $-w, nil
      src, out = XMP2Assert::Converter.convert expr
      if out.empty?
        src.eval binding
      else
        suppress do
          src.eval binding
        end
        assert_capture2e(out, src)
      end
    ensure
      $-w = v
    end
  end
end
