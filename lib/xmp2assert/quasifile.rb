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

require 'open-uri'
require 'pathname'
require_relative 'namespace'
require_relative 'prettier_inspect'

# XMP2Assert  converts a  ruby script  into a  test file  but we  want to  hold
# original path name / line number for diagnostic purposes.  So this class.
class XMP2Assert::Quasifile
  include XMP2Assert::PrettierInspect

  # @return [Quasifile] a new quasifile.
  #
  # @overload new(qfile)
  #   Just return the given object (for possible recursive calls).
  #
  #   @param  qfile [Quasifile]  an instance of this class.
  #   @return       [Quasifile]  identical to the argunemt.
  #
  # @overload new(uri, file = uri.to_s, line = 1)
  #   Obtains the  resource pointed by the  URI, parses the resource  as a ruby
  #   script, and constructs a quasifile according to that.
  #
  #   @param  uri   [URI]                a URI of a ruby script.
  #   @param  file  [String]             file path.
  #   @param  line  [Integer]            line offset.
  #   @return       [Quasifile]          generated quasifile.
  #   @raise        [OpenURI::HTTPError] 404 and such.
  #
  # @overload new(path, file = path.to_path, line = 1)
  #   Same as uri version, but accepts a pathname instead.
  #
  #   @param  path  [#to_path]       a pathname that points to a ruby script.
  #   @param  file  [String]         file path.
  #   @param  line  [Integer]        line offset.
  #   @return       [Quasifile]      generated qiasifile.
  #   @raise        [Errno::ENOENT]  not found.
  #   @raise        [Errno::EISDIR]  path is directory.
  #   @raise        [Errno::EACCESS] permission denied.
  #   @raise        [Errno::ELOOP]   infinite symlink.
  #
  # @overload new(io, file = '(eval)', line = io.lineno + 1)
  #   Same  as pathname  version, but  it  also directly  accepts arbitrary  IO
  #   instances to read ruby scripts from.  It migth be handy for you to pass a
  #   pipe here.  The  script filename may or may not  be inferred depending on
  #   the IO  (Files might  be able  to, Sockets  hardly likely).   Failures in
  #   filename  resolution do  not render  exceptions.  Rather  the info  lacks
  #   silently.
  #
  #   @param  io    [#to_io]    an IO that can be read.
  #   @param  file  [String]    file path.
  #   @param  line  [Integer]   line offset.
  #   @return       [Quasifile] generated qiasifile.
  #   @raise        [IOError]   io not open for read, already closed, etc.
  #
  # @overload new(str, file = '(eval)', line = 1)
  #   Same as  io version,  but it  also directly  accepts a  ruby script  as a
  #   string.  Obviously in this case, you cannot infer its filename.
  #
  #   @param  str   [#to_io]    a content of a ruby script.
  #   @param  file  [String]    file path.
  #   @param  line  [Integer]   line offset.
  #   @return       [Quasifile] generated qiasifile.
  #
  def self.new(obj, file = nil, line = nil)
    case
    when src  = switch { obj.to_str  } then # LIKELY
      return allocate.tap do |ret|
        ret.send(:initialize, src, file||'(eval)', line||1)
      end
    when self              === obj     then return obj
    when OpenURI::OpenRead === obj     then src, path = obj.read, obj.to_s
    when path = switch { obj.to_path } then src       = obj.read
    when io   = switch { obj.to_io   } then off, src  = io.lineno+1, io.read
    when src  = switch { obj.read    } then # unknown class but works
    else
      raise TypeError, "something readable expected but given: #{obj.class}"
    end

    return new(src, file || path, line || off) # recur
  end

  def self.switch
    return yield
  rescue NoMethodError
    return nil
  end
  private_class_method :switch

  attr_reader :__FILE__     # @return [String]   file name of this script.
  attr_reader :__LINE__     # @return [Integer]  line offset.
  attr_reader :__ENCODING__ # @return [Encoding] script encoding.
  attr_reader :read         # @return [String]   content of the ruby script.

  # @param  content [String]    a content of a ruby script.
  # @param  file    [String]    file path.
  # @param  line    [Integer]   line offset.
  def initialize(content, file, line)
    @__FILE__     = file
    @__LINE__     = line
    @__ENCODING__ = content.encoding
    @read         = content
  end

  # Eavluate the content script
  # @param  b [Binding] target binding (default toplevel).
  # @return             anything that the content evaluates.
  def eval b = TOPLEVEL_BINDING
    Kernel.eval @read, b, @__FILE__, @__LINE__
  end

  unless $DEBUG
    # @!group Inspection

    # For pretty print
    def pretty_print_instance_variables
      return %w'@__FILE__ @__LINE__'
    end

    # @!endgroup
  end
end
