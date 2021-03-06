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

require_relative 'namespace'

# An XMP comment normally looks like this:
#
# ```ruby
# Object.new   # => #<Object:0x007f896c9b49c8>
# ```
#
# Here, the hexadecimal  number 0x007f896c9b49c8 is the raw  pointer address of
# this evaluated  object.  When we  check sanity of  this XMP, that  part would
# never match because pointer addresses are kind of arbitrary.
#
# To  reroute  the problem,  here  we  convert a  XMP  comment  into a  regular
# expression.  The  idea behind this  is the  diff process hook  implemented in
# https://github.com/ruby/chkbuild
class XMP2Assert::XMP2Rexp
  # Generates a regular expression that roughly matches the input.
  # @param xmp [String] example.
  # @return    [Regexp] converted regular expression.
  def self.xmp2rexp xmp
    # :NOTE: we are  editing regular expressions using  regular expressions. In
    # order  to hack  this method  you must  be a  seasoned regular  expression
    # craftsperson who can count backslashes at ease.
    nln = /\n*\z/.match(xmp).to_s.length
    src = Regexp.escape xmp.strip
    src.gsub!(/([^\\])(\\n|\\ )+/, '\\1\s+')
    src.gsub!(/(#<[\w:]+?:)0x[0-9a-f]+/, '\\10x[0-9a-f]+')
    src.gsub!(/\\u\\{([0-9a-f]{1,4})\\}/) {
      str = $1
      len = 4 - str.length
      pad = '0' * len
      next sprintf '\\u(?:%s%s|\\{%s\\})', pad, str.upcase, str
    }
    src.gsub!(/\\u([0-9A-F]{4})/) {
      str = $1
      hex = str.each_char.drop_while {|i| i == '0' }.join # :FIXME: slow?
      next sprintf '\\u(?:%s|\\{%s\\})', str, hex.downcase
    }
    src.gsub!(/\\\.rb:\d+/, '\\.rb:\d+')
    src.gsub!(/(\\\.){3}/, '.+?')

    case nln when 0, 1 then
      return Regexp.new "\\A#{src}\\n?\\z"
    else
      return Regexp.new "\\A#{src}\\n{#{nln}}\\z"
    end
  end
end
