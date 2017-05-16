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

require 'erb'
require 'pathname'
require 'tempfile'
require_relative 'namespace'
require_relative 'quasifile'

# Compiles a {XMP2Assert::Quasifile} into a separate ruby script.
class XMP2Assert::Renderer

  # I learned this handy "super-private" maneuver from @a_matsuda
  # cf: https://github.com/rails/rails/pull/27363/files
  using Module.new {
    refine XMP2Assert::Renderer.singleton_class do
      private

      myself = Pathname.new __FILE__
      path   = myself + '../template.erb'
      src    = path.read mode: 'rb:binary:binary'
      erb    = ERB.new src, nil, '%-'
      eval <<-"end", binding, path.realpath.to_path, -1
        def erb(script, exception)\n#{erb.src}\nend
      end
    end
  }

  public

  # Compiles a {Quasifile} into a  separate ruby script.  Generated file should
  # be passable to a separate ruby process.   This method yields that file if a
  # block is given, and deletes it afterwards.  When no block is passed, leaves
  # it undeleted; to clean it up is up to the caller then.
  #
  # @param qfile     [Quasifile] a file to convert to.
  # @param exception [String]    :TBD:
  # @return          [File]      rendered file, if no block is given.
  # @yieldparam      [File]      rendered file, if block is given.
  def self.render qfile, exception = nil
    s = erb qfile, exception
    if defined? yield
      Tempfile.create '' do |f|
        f.write s
        f.flush
        return yield f
      end
    else
      f = Tempfile.create ''
      f.write s
      f.flush
      return f
    end
  end
end
