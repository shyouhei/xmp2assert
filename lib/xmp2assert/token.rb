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
require_relative 'prettier_inspect'

# Token is a tiny class that represents a token of a Ruby program.
#
# @!attribute [rw]     yylex
#     @return [Symbol] terminal symbol
# @!attribute [rw]     yylval
#     @return [String] terminal value
# @!attribute [rw]     yylloc
#     @return [Array]  terminal location
XMP2Assert::Token = Struct.new :yylex, :yylval, :yylloc do
  include Comparable

  # Comparison of location in a file, to be used with sort.
  # @param other [Token] token to compare
  def <=> other
    yylloc <=> other.yylloc
  end

  alias to_sym yylex
  alias to_s yylval

  # @!group Token locations

  # @return [String] file name
  def __FILE__
    return yylloc[0]
  end

  # @return [String] line number (1 origin)
  def __LINE__
    return yylloc[1]
  end

  # @return [String] column in a line
  def __COLUMN__
    return yylloc[2]
  end
  # @!endgroup

  # Considet this token being an error.
  # @param klass [Exception] exception to raise
  # @param msg   [String]    diagnostic message
  def raise klass = SyntaxError, msg = ""
    l = sprintf "%s:%s", self.__FILE__, self.__LINE__
    m = sprintf 'syntax error near "%s" at line %d:%d %s',
          to_s, self.__LINE__, self.__COLUMN__, msg
    super klass, m, [l, *caller]
  end

  unless $DEBUG
    include ::XMP2Assert::PrettierInspect

    def pretty_print pp
      pp.text "("
      yylex.pretty_print pp
      pp.breakable " "
      yylval.pretty_print pp
      pp.text ")"
    end
  end
end
