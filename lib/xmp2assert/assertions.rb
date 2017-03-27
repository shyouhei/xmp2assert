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

require 'rbconfig'
require 'open3'
require 'tempfile'
require 'erb'
require 'test/unit'
require 'test/unit/assertions'
require 'test/unit/assertion-failed-error'
require_relative 'xmp2rexp'

# Helper module that implements assertions.
module XMP2Assert::Assertions
  include Test::Unit::Assertions
  include XMP2Assert::XMP2Rexp

  # Run a ruby script and assert for its output.
  #
  # ```ruby
  # assert_capture2e "foo\n", Quasifile.new("puts 'foo'")
  # ```
  #
  # @param expected [String]               expected output.
  # @param script   [Quasifile]            a ruby script.
  # @param message  [String]               extra failure message.
  # @param rubyopts [Array<String>]        extra opts to pass to ruby process.
  # @param opts     [Hash{Symbol=>Object}] extra opts to pass to spawn.
  # @note
  #   As the method name implies the assertion is against both stdin and stderr
  #   at once.  This is for convenience.
  def assert_capture2e expected, script, message = nil, rubyopts: nil, **opts
    actual, _ = ruby script, rubyopts: rubyopts, **opts
    actual.force_encoding expected.encoding
    return assert_xmp_raw expected, actual, message
  end

  # Assert if the given expression is in the same form of xmp.
  #
  # ```ruby
  # assert_xmp '#<Object:0x007f896c9b49c8>', Object.new
  # ```
  #
  # @param xmp      [String] expected pattern of inspect.
  # @param expr     [Object] object to check.
  # @param message  [String] extra failure message.
  def assert_xmp xmp, expr, message = nil
    assert_xmp_raw xmp, expr.inspect, message
  end

  private

  # :TODO: is it private?
  def assert_xmp_raw xmp, actual, message = nil
    msg      = genmsg xmp, actual, message
    expected = xmp2rexp xmp

    raise unless expected.match actual
  rescue
    # Regexp#match can raise. That should also be a failure.
    ix = Test::Unit::Assertions::AssertionMessage.convert xmp
    ia = Test::Unit::Assertions::AssertionMessage.convert actual
    ex = Test::Unit::AssertionFailedError.new(msg,
                  expected: xmp,
                    actual: actual,
        inspected_expected: ix,
          inspected_actual: ia,
              user_message: message)
    raise ex
  else
    return self # or...?
  end

  # We support pre-&. versions
  def try obj, msg
    return obj.send msg
  rescue NoMethodError
    return nil
  end

  def genmsg x, y, z = nil
    diff = Test::Unit::Assertions::AssertionMessage.delayed_diff x, y
    if try(x, :encoding) != try(y, :encoding) then
      fmt  = "<?>(?) expected but was\n<?>(?).?"
      argv = [x, x.encoding.name, y, y.encoding.name, diff]
    else
      fmt  = "<?> expected but was\n<?>.?"
      argv = [x, y, diff]
    end
    return Test::Unit::Assertions::AssertionMessage.new z, fmt, argv
  end

  def erb
    unless defined? @@erb
      myself = Pathname.new __FILE__
      path   = myself + '../template.erb'
      src    = path.read mode: 'rb:binary:binary'
      @@erb  = ERB.new src, nil, '%-'
      @@erb.filename = path.realpath.to_path if defined? $DEBUG
    end
    return @@erb
  end

  def empty_binding
    # This `eval 'binding'` does not return the current binding but creates one
    # on top  of it.  To  make it  really empty, this  method has to  have zero
    # arity, and zero local variables.
    return eval 'binding'
  end

  def empty_binding_with hash
    return empty_binding.tap do |b|
      hash.each_pair do |k, v|
        b.local_variable_set k, v
      end
    end
  end

  def ruby script, rubyopts: nil, **opts
    Tempfile.create '' do |f|
      b = empty_binding_with script: script
      s = erb.result b
      f.write s
      argv = [RbConfig.ruby, rubyopts, f.path]
      if defined? ENV['BUNDLE_BIN_PATH']
        argv = [ENV['BUNDLE_BIN_PATH'], 'exec'] + argv
      end
      argv.flatten!
      argv.compact!
      f.flush
      # STDERR.puts(f.path) ; sleep # for debug
      return Open3.capture2e(*argv, binmode: true, **opts)
    end
  end
end
