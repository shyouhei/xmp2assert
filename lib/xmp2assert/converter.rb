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
require 'uuid'
require_relative 'namespace'
require_relative 'quasifile'
require_relative 'token'
require_relative 'validator'

# This class converts a Ruby script into assertions
class XMP2Assert::Converter < Ripper
  private_class_method :new

  # Detects XMP and make them assertions.  For example:
  #
  # ```ruby
  # def foo; 2; end
  # 1 + foo # => 3
  # ```
  #
  # would become
  #
  # ```ruby
  # def foo; 2; end
  # (1 + foo).tap {|i| assert_xmp("3", i ) }
  # ```
  #
  # @param  program  [Quasifile] file-ish.
  # @param  filename [String]    filename of program.
  # @param  lineno   [Integer]   line offset.
  # @return [(Quasifile,String)] tuple  of  generated  file  and  its  expected
  #                              output.
  def self.convert program, filename = nil, lineno = nil
    qfile = XMP2Assert::Quasifile.new program, filename, lineno
    this = new qfile.read, qfile.__FILE__, qfile.__LINE__
    src, out = this.send :convert
    ret = XMP2Assert::Quasifile.new src, qfile.__FILE__, qfile.__LINE__
    return ret, out
  end

  private

  def initialize *;
    super
    @tokens = []
  end

  def convert
    parse
    @tokens.sort!
    outputs = aggregate
    merge_xmp
    render
    return @tokens.join, outputs.join
  end

  def gensym expr
    n = UUID.create_sha1 expr, Namespace
    n = n.to_uri
    n.gsub! %r/[:-]/, '_'
    return n
  end

  Namespace = UUID.create_random
  private_constant :Namespace

  def gen_tap xmp
    n = gensym xmp
    x = xmp.chomp.dump
    return sprintf ".tap {|%s| assert_xmp(%s, %s) }", n, x, n
  end

  def end_of_expr? tok
    case tok.to_sym
    when :sp          then return false
    when :comma       then return false
    when :semicolon   then return false
    when :comment     then return false
    when :__xmp__     then return false
    when :nl          then return false
    when :ignored_nl  then return false
    when :heredoc_end then return nil # give up. too complicated
    when :kw          then
      case tok.to_s
      when 'then'     then return false
      when 'end'      then return nil # give up. too complicated
      else                 return true
      end
    else                   return true
    end
  end

  def beginning_of_expr? tok
    case tok.to_sym
    when :semicolon   then return true
    when :comment     then return true
    when :__xmp__     then return true
    when :nl          then return true
    when :ignored_nl  then return true
    else                   return false
    end
  end

  def find_stop pos
    (pos - 1).downto 0 do |i|
      case end_of_expr? @tokens[i]
      when TrueClass  then return true, i
      when FalseClass then next
      when NilClass   then return nil, i + 1
      end
    end
    # reaching here indicates no stop; fatal.
    @tokens[pos].raise
  end

  # :FIXME: this is O(n^2)
  def find_start pos
    pos.downto 0 do |i|
      next unless beginning_of_expr? @tokens[i]
      (i + 1).upto pos do |j|
        return j if XMP2Assert::Validator.valid? @tokens[j..pos].join
      end
      return nil # give up
    end
    0.upto pos do |j|
      return j if XMP2Assert::Validator.valid? @tokens[j..pos].join
    end
    return 0 # or...?
  end

  def rev_lookup_expr pos
    needs_start, stop = find_stop pos
    return nil, stop unless needs_start
    start = find_start stop
    return start, stop
  end

  def aggregate
    return @tokens.inject [] do |r, tok|
      next r unless :comment ==  tok.to_sym
      next r unless /^# [~>]>\s+/ =~ tok.to_s
      tok.to_s.replace "#\n"
      r << Regexp.last_match.post_match
    end
  end

  def merge_xmp
    xmp = nil
    @tokens.each do |tok|
      case tok.to_sym
      when :sp then next
      when :comment then
        str = tok.to_s
        next unless /^# =>\s+/ =~ str
        if xmp then
          xmp << Regexp.last_match.post_match
          str.replace "#\n"
        else
          tok.yylex = :__xmp__ # introducing new token...
          xmp = tok.to_s
          xmp.replace Regexp.last_match.post_match
        end
      else
        xmp = nil
      end
    end
  end

  def render
    @tokens.each_with_index do |tok, i|
      next unless tok.to_sym == :__xmp__
      xmp = tok.to_s
      tap = gen_tap xmp
      xmp.replace "\n"
      x, y = rev_lookup_expr i
      if x and x != y then
        @tokens[x].to_s.sub! %r/^/, '('
        @tokens[y].to_s.sub! %r/$/, ')'
      end
      @tokens[y].to_s.sub! %r/$/ do
        tap # use block to prevent backslash substitution
      end
    end
  end

  def on_scanner_event yylval
    yylex = __callee__.to_s.sub(/^on_/, '').intern
    yylloc = [filename, lineno, column]
    tok = XMP2Assert::Token.new yylex, yylval, yylloc
    @tokens << tok
    return nil
  end

  pim = private_instance_methods false
  SCANNER_EVENTS.each do |e|
    m = :"on_#{e}"
    alias_method m, :on_scanner_event unless pim.include? m
  end
end
