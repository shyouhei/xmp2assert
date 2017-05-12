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

require 'ripper'
require_relative 'namespace'
require_relative 'quasifile'
require_relative 'token'

# This is a Ruby parser. Generates ASTs from the given program.
class XMP2Assert::Parser < Ripper
  attr_reader :tokens # @return [Array<Token>] program, split into tokens.
  attr_reader :sexp   # @return [Array]        constructed s-expression.

  # @param (see XMP2Assert::Quasifile.new)
  # @raise [SyntaxError] failed to parse the program.
  def initialize obj, file = nil, line = nil
    @qfile = XMP2Assert::Quasifile.new obj, file, line
    super @qfile.read, *locations
    @tokens = []
    @sexp = parse
    @tokens.sort!
  end

  # @return [String, Integer] the program's file name and line offset.
  def locations
    return @qfile.__FILE__, @qfile.__LINE__
  end

  # Find tokens that are in the same line as the argument.
  #
  # ```ruby
  # [ 1, # => 1
  #   2, # => 2
  # ]    # => [1, 2]
  # ```
  #
  # It will return `[(:sp ' ') (:int 2) (:'=>' "2")]` for `(:'=>' "2")`.
  #
  # @param tok [Token] a token to look at.
  # @return    [Array] tokens of the same line as the argument.
  def same_line_as tok
    f, l = tok.__FILE__, tok.__LINE__
    return @tokens.select {|i| i.__FILE__ == f }.select {|i| i.__LINE__ == l }
  end

  private

  def on_error msg
    raise SyntaxError, msg
  end

  def on_comment c
    case c
    when /^# ([~=!>]>) / then
      yylex = $1.intern
      yylval = $'
    else
      yylex = :comment
      yylval = c
    end
    yylloc = [filename, lineno, column]
    tok = XMP2Assert::Token.new yylex, yylval, yylloc
    @tokens << tok
    return tok
  end

  def on_scanner_event yylval
    yylex = __callee__.to_s.sub(/^on_/, '').intern
    yylloc = [filename, lineno, column]
    tok = XMP2Assert::Token.new yylex, yylval, yylloc
    @tokens << tok
    return tok
  end

  def on_parser_event *argv
    nonterminal = __callee__.to_s.sub(/^on_/, '').intern
    return [nonterminal, *argv]
  end

  def on_parser_list_new *argv
    nonterminal = __callee__.to_s.sub(/^on_(.+)_new$/, '\\1').intern
    raise [__callee__, argv].inspect unless argv.empty?
    return [nonterminal]
  end

  def on_parser_list_append list, cdr
    return list << cdr
  end

  pim = private_instance_methods false

  SCANNER_EVENTS.each do |e|
    m = :"on_#{e}"
    next if pim.include? m
    alias_method m, :on_scanner_event
  end

  PARSER_EVENTS.each do |e|
    m = :"on_#{e}"
    next if pim.include? m
    case m
    when :on_assoc_new then alias_method m, :on_parser_event
    when /_new$/       then alias_method m, :on_parser_list_new
    when /_add$/       then alias_method m, :on_parser_list_append
    else                    alias_method m, :on_parser_event
    end
  end

  alias on_parse_error on_error
  alias compile_error  on_error
end
