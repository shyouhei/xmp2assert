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

# This is a tiny ripper extension that checks one thing; if a given string is a
# valid ruby program or not.
#
# ```ruby
# Pathname.glob('**/*.rb').select do |f|
#   XMP2Assert::Validator.valid?(f)
# end
# ```
class XMP2Assert::Validator < Ripper
  private_class_method :new

  # @param program  [Quasifile]  a ruby program candidate.
  # @param filename [String]     program's path.
  # @param lineno   [Integer]    program's line number.
  # @return         [TrueClass]  the given program is a valid ruby program.
  # @return         [FalseClass] it isn't.
  def self.valid? program, filename = nil, lineno = nil
    qfile = XMP2Assert::Quasifile.new program, filename, lineno
    this = new qfile.read, qfile.__FILE__, qfile.__LINE__
    this.parse
  rescue
    return false
  else
    return true
  end

  private

  alias on_parse_error raise
  alias compile_error raise
end
