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
require_relative 'parser'

# Usually, you  want to check  LOTS of  files that may  or may not  contain xmp
# comments at once, maybe  from inside of a CI process.  That's  OK but we want
# to speed  things up, so here  we filter out  files that are not  necessary to
# convert.
#
# Typical usage:
#
# ```ruby
# Pathname.glob('**/*.rb').select do |f|
#   XMP2Assert::Classifier.classify(f)
# end
# ```
module XMP2Assert::Classifier
  # @param  (see XMP2Assert::Parser.new)
  # @return [<Symbol>]  any combination of :=>, :>>, :!>, :~>, or empty.
  # @note               syntax error results in empty return value.
  def self.classify obj, file = nil, line = nil
    parser = XMP2Assert::Parser.new obj, file, line
  rescue SyntaxError
    return []
  else
    mid = %i[=> >> !> ~>]
    return parser                                      \
      .tokens                                          \
      .map(&:to_sym)                                   \
      .sort                                            \
      .uniq                                            \
      .map {|i| case i when *mid then i else nil end } \
      .compact
  end
end
