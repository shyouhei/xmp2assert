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

class XMP2Assert::Converter < Ripper
  private_class_method :new

  def self.convert qfile
    case qfile when XMP2Assert::Quasifile then
      this = new qfile.read, qfile.__FILE__, qfile.__LINE__
      s, o = this.send :convert
      r = XMP2Assert::Quasifile.new s, qfile.__FILE__, qfile.__LINE__
      return r, o
    else
      q = XMP2Assert::Quasifile.new qfile
      return convert q
    end
  end

  private

  def pos
    return [filename, lineno, column]
  end

  def convert
    @ret = []
    @xmps = []
    @last_seen_xmp = nil
    @outputs = String.new
    parse
    postprocess
    return @ret.join, @outputs
  end

  def postprocess
    @ret.sort!
    @ret.map! do |(_, xmp, tok)|
      if xmp
        n = UUID.create_sha1 tok, Namespace
        n = n.to_uri
        n.gsub! %r/[:-]/, '_'
        sprintf ".tap {|%s| assert_xmp(%s, %s) }\n", n, tok.chomp.dump, n
      else
        tok
      end
    end
  end

  Namespace = UUID.create_random
  private_constant :Namespace

  def on_comment tok
    xmp = false
    case tok
    when /^\# [~>]> (.+\n)/ then
      @outputs << $1
    when /^\# => (.+\n)/ then
      if @last_seen_xmp
        @last_seen_xmp << $1
        tok = "#\n"
      else
        tok = @last_seen_xmp = $1
        xmp = true
      end
    else
      @last_seen_xmp = nil
    end
    @ret << [pos, xmp, tok]
  end

  def on_sp tok
    # no reset @last_seen_xmp
    @ret << [pos, false, tok]
  end

  def on_scanner_event tok
    @last_seen_xmp = nil
    @ret << [pos, false, tok]
  end

  pim = private_instance_methods false
  SCANNER_EVENTS.each do |e|
    m = :"on_#{e}"
    unless pim.include? m then
      alias_method m, :on_scanner_event
    end
  end
end
