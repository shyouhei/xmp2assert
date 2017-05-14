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

require 'uuid'
require_relative 'namespace'
require_relative 'parser'
require_relative 'quasifile'

# This class converts a Ruby script into assertions
class XMP2Assert::Converter
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
  # @param  (see #initialize)
  # @return (see #convert)
  def self.convert obj, file = nil, line = nil
    this = new obj, file, line
    return this.send :convert
  end

  private

  # @param (see XMP2Assert::Parser.new)
  def initialize obj, file = nil, line = nil
    @program = XMP2Assert::Parser.new obj, file, line
  end

  # @return [(Quasifile,String,String,String)]
  #   a  tuple  of  comment-converted  source, its  expected  stdout,  expected
  #   stderr, and expected exception.
  def convert
    @tokens = @program.tokens
    understand
    stdout, stderr, exceptions = aggregate
    render
    ret = XMP2Assert::Quasifile.new @tokens.join, *@program.locations
    return ret, stdout, stderr, exceptions
  end

  def gensym expr
    n = UUID.create_sha1 expr, Namespace
    n = n.to_uri
    n.gsub! %r/[:-]/, '_'
    return n
  end

  Namespace = UUID.create_random
  private_constant :Namespace

  def gen_tap tok
    xmp = tok.to_s.chomp.dump
    case tok.to_sym
    when :'~>' then
      return sprintf " rescue (xmp2assert_assert(%s, $!) and raise)", xmp
    when :'=>' then
      nam = gensym xmp
      return sprintf ".tap {|%s| xmp2assert_assert(%s, %s) }", nam, xmp, nam
    end
  end

  def end_of_expr? tok
    case tok.to_sym
    when :sp          then return false
    when :comma       then return false
    when :semicolon   then return false
    when :comment     then return false
    when :'=>'        then return false
    when :'!>'        then return false
    when :'~>'        then return false
    when :>>          then return false
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
    when :sp          then return false
    when :kw          then
      case tok.to_s
      when 'return'   then return false
      when 'next'     then return false
      when 'break'    then return false
      else                 return true
      end
    else                   return true
    end
  end

  def find_stop xmp
    pos = @tokens.index xmp
    (pos - 1).downto 0 do |i|
      case end_of_expr? @tokens[i]
      when TrueClass  then return true, @tokens[i]
      when FalseClass then next
      when NilClass   then return nil, @tokens[i + 1]
      end
    end
    # reaching here indicates no stop; fatal.
    @tokens[pos].raise
  end

  def valid? line
    XMP2Assert::Parser.new line.join
  rescue SyntaxError
    return false
  else
    return true
  end

  def tmp_reroute_heredoc line
    return line.map do |tok|
      case tok.to_sym when :heredoc_beg then
        next XMP2Assert::Token.new :'""', '""', tok.yylloc
      else
        next tok
      end
    end
  end

  def revert_heredoc before, after
    after.map! do |tok|
      case tok.to_sym when :'""' then
        next before.find {|i| i.yylloc == tok.yylloc }
      else
        next tok
      end
    end
    before.replace after
  end

  def find_start stop
    line = @program.same_line_as stop
    line.sort!
    line.select! {|i| i.__COLUMN__ <= stop.__COLUMN__ }
    line = line.drop_while {|i| not beginning_of_expr? i }
    line2 = tmp_reroute_heredoc line
    until valid? line2 do
      line2.shift
    end
    revert_heredoc line, line2
    return line
  end

  def need_paren? list
    start = list.first.to_sym.to_s

    if "embexpr_beg" == start then
      return false # paren breaks expression

    elsif %r/(.+)_beg$/ =~ start then
      t = $1
      list.inject 0 do |i, tok|
        tt = tok.to_sym.to_s
        if %r/#{t}_beg$/ =~ tt
          next i + 1
        elsif %r/#{t}_end$/ =~ tt
          j = i - 1
          if j > 0 then
            next j
          elsif tok == list.last
            return false
          else
            return true
          end
        else
          next i
        end
      end
      return true

    elsif %r/^l(paren|brace|bracket)$/ =~ start then
      t = $1
      list.inject 0 do |i, tok|
        tt = tok.to_sym.to_s
        if %r/^l#{t}$/ =~ tt
          next i + 1
        elsif %r/^r#{t}$/ =~ tt
          j = i - 1
          if j > 0 then
            next j
          elsif tok == list.last
            return false
          else
            return true
          end
        else
          next i
        end
      end
      return true

    else
      return true
    end
  end

  # 1. take the line that has xmp.
  # 2. if that line is syntactically valid, use it.
  # 3. pop some tokens so that punctuations disappear, e.g. take `1` for
  #
  #    ```ruby
  #    {
  #      one:
  #      1, # => 1
  #    }
  #    ```
  #
  # 4. shift some tokens so that parens etc. disappear, e.g. take `1` for
  #
  #    ```ruby
  #    {
  #      one: 1, # => 1
  #    }
  #    ```
  #
  # 5. if  above 3  and  4 resulted  in  deleting all  tokens,  that means  the
  #    expression started before that line.  Give up and take the whole line to
  #    expect it peacefully terminates something. e.g. take `}` for
  #
  #    ```ruby
  #    {
  #      one: 1,
  #    } # => {:one=>1}
  #    ```
  def rev_lookup_expr xmp
    needs_start, stop = find_stop xmp
    return nil, stop unless needs_start
    list = find_start stop

    if list.empty? then
      return nil, stop
    elsif need_paren? list then
      return list.first, stop
    else
      return nil, stop
    end
  end

  def understand
    xmp = nil
    @tokens.each do |tok|
      case sym = tok.to_sym
      when :'=>', :>>, :'!>', :'~>' then
        if xmp and xmp.to_sym == sym then
          xmp.to_s.concat tok.to_s
          tok.yylex  = :comment
          tok.yylval = "#\n"
        else
          xmp = tok
        end
      when :comment then
        if xmp then
          xmp.to_s.concat tok.to_s.sub(/^#/, '')
          tok.yylval = "#\n"
        else
          xmp = nil
        end
      when :sp then
        next # ignore spaces
      else
        xmp = nil
      end
    end
  end

  def aggregate
    buf = Hash.new "" # ok
    @tokens.reverse_each do |tok|
      case sym = tok.to_sym
      when :>>, :'!>', :'~>' then
        buf[sym] = tok.to_s << buf[sym]
        tok.yylex  = :comment
        tok.yylval = "#\n"
      when :sp, :nl then
        next
      else
        break
      end
    end
    # aggregation of ~> stops here, others continue.
    @tokens.reverse_each do |tok|
      case sym = tok.to_sym when :>>, :'!>' then
        buf[sym] = tok.to_s << buf[sym]
        tok.yylex  = :comment
        tok.yylval = "#\n"
      end
    end
    return buf.values_at :>>, :'!>', :'~>'
  end

  def render
    @tokens.each do |tok|
      case tok.to_sym when :'=>', :'~>' then
        tap = gen_tap tok
        tok.to_s.replace "\n"
        x, y = rev_lookup_expr tok
        if x and x != y then
          x.to_s.sub! %r/^/, '('
          y.to_s.sub! %r/$/, ')'
        end
        y.to_s.sub! %r/$/ do
          tap # use block to prevent backslash substitution
        end
      end
    end
  end
end
