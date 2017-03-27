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

# This is a namespace.  Look at each classes under this module:
#
# - XMP2Assert::Assertions    the assertion framework.
# - XMP2Assert::Classifier    check if the given file actually has the comment.
# - XMP2Assert::Converter     source code in-place editor using Ripper.
# - XMP2Assert::Quasifile     IO/String abstraction layer
# - XMP2Assert::PrttierInpect helper module to ease inspection.
module XMP2Assert
  # These files assume the namespace, hence required here inside.
  require_relative 'xmp2assert/version'
  require_relative 'xmp2assert/prettier_inspect'
  require_relative 'xmp2assert/quasifile'
  require_relative 'xmp2assert/converter'
  require_relative 'xmp2assert/classifier'
  require_relative 'xmp2assert/assertions'
end
