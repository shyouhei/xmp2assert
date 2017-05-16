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
require_relative 'namespace'

# Helper class to spawn a ruby process, and communicate with it.
class XMP2Assert::Spawn

  # @param path        [#to_path]      a path to a ruby program.
  # @param rubyopts    [Array<String>] extra opts to pass to ruby interpreter.
  # @param opts        [Hash]          extra opts to pass to Process.spawn
  # @yieldparam pid    [Integer]       child process' pid.
  # @yieldparam stdin  [IO]            child process stdin.
  # @yieldparam stdout [IO]            child process stdout.
  # @yieldparam stderr [IO]            child process stderr.
  # @yieldparam tx     [IO]            pipe to communicate.
  # @yieldparam rx     [IO]            pipe to communicate.
  def initialize path, rubyopts: nil, **opts
    ours, theirs, spec = pipes %i'r w w r w'
    opts.update Hash[spec]

    argv = [RbConfig.ruby, rubyopts, path.to_path]
    argv << theirs[3..4].map {|i| i.to_i.to_s }
    argv.flatten!
    argv.compact!

    begin
      pid = Process.spawn(*argv, opts)
      theirs.each(&:close)
      stdin, stdout, stdrrr, rx, tx = *ours
      yield pid, stdin, stdout, stdrrr, rx, tx
    ensure
      begin
        ours.each(&:close)
      rescue IOError
        # OK, nothing can be done by us for closed streams.
      ensure
        Process.waitpid pid if pid
      end
    end
  end

  private

  def pipes directions
    ours = []
    theirs = []
    directions.each_with_index do |d, i|
      r, w = IO.pipe
      t = (d == :r) ? r : w
      o = (d == :r) ? w : r
      theirs[i] = t
      ours[i]   = o
      o.sync = true
      o.binmode
    end
    iospec = theirs.map {|i| [i, i] }
    iospec[0][0] = 0
    iospec[1][0] = 1
    iospec[2][0] = 2
    return ours, theirs, iospec
  end
end
