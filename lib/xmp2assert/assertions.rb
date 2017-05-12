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

require 'test/unit'
require 'test/unit/assertions'
require 'test/unit/assertion-failed-error'
require_relative 'namespace'
require_relative 'quasifile'
require_relative 'xmp2rexp'
require_relative 'renderer'
require_relative 'spawn'

# Helper module that implements assertions.
module XMP2Assert::Assertions
  include Test::Unit::Assertions
  include XMP2Assert::XMP2Rexp
  include XMP2Assert::Renderer

  # Run a ruby script and assert for its comment.  This is the main API.
  #
  # ```ruby
  # assert_xmp "1 + 2 # => 3"
  # ```
  #
  # @param script     [Quasifile]     a ruby script.
  # @param message    [String]        extra failure message.
  # @param rubyopts   [Array<String>] extra opts to pass to ruby process.
  # @param stdin_data [String]        extra stdin to pass to ruby process.
  # @param opts       [Hash]          extra opts to pass to Kernel.spawn.
  def assert_xmp script, message = nil, stdin_data: '', **opts
    qscript        = XMP2Assert::Quasifile.new script
    qf, qo, qe, qx = XMP2Assert::Converter.convert qscript
    render qf, qx do |f|
      XMP2Assert::Spawn.new f, **opts do |_, i, o, e, r, t|
        i.write stdin_data
        i.close
        out = Thread.new { o.read }
        err = Thread.new { e.read }
        while n = t.gets do
          x = t.read n.to_i
          expected, actual, bt = *Marshal.load(x)
          begin
            assert_xmp_raw expected, actual, message
          rescue Test::Unit::AssertionFailedError => x
            r.close
            x.set_backtrace bt
            raise x
          else
            r.puts
          end
        end
        assert_xmp_raw qo, out.value, message unless qo.empty?
        assert_xmp_raw qe, err.value, message unless qe.empty?
      end
    end
  end

  # :TODO: tbw
  def assert_xmp_raw xmp, actual, message = nil
    expected = xmp2rexp xmp

    raise unless expected.match actual
  rescue
    # Regexp#match can raise. That should also be a failure.
    ix  = Test::Unit::Assertions::AssertionMessage.convert xmp
    ia  = Test::Unit::Assertions::AssertionMessage.convert actual
    ex  = Test::Unit::AssertionFailedError.new(message,
                    expected: xmp,
                      actual: actual,
          inspected_expected: ix,
            inspected_actual: ia,
                user_message: message)
    raise ex
  else
    return self # or...?
  end
end
