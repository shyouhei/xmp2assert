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

zde = (1/0 rescue $!)

class Hash
  undef []
  undef []=
  undef fetch
end
class IO
  undef sync
  undef <<
    undef flush
  undef puts
  undef close
end
class Queue
  undef <<
    undef shift
  undef clear
end
class Symbol
  undef ==
    undef to_s
  undef inspect
end
class String
  undef ==
  undef to_s
  undef to_str
  undef inspect
  undef to_i
end
class Integer
  undef <
  undef <<
  undef ==
  def next # "redefining instead of undefing b/c it comes from Integer"
  end
  undef to_s
  undef inspect
end
class Array
  undef pack
  undef <<
    undef to_ary
  undef grep
  undef first
  undef []
  undef []=
  undef each
  undef map
  undef join
  undef size
  undef to_s
end
class << Marshal
  undef dump
  undef load
end
module Kernel
  undef kind_of?
  undef block_given?
end
module Enumerable
  undef map
end
class SystemExit
  undef status
end
class Exception
  undef message
  # undef backtrace # https://bugs.ruby-lang.org/issues/12925
  def class
    "totally the wrong thing"
  end
end
class << Thread
  undef new
  undef current
end
class Thread
  undef join
  undef abort_on_exception
end
class Class
  undef new
  undef allocate
  undef singleton_class
  undef class_eval
end
class BasicObject
  undef initialize
end
class Module
  undef ===
  undef define_method
  undef instance_method
end
class UnboundMethod
  undef bind
end
class Method
  undef call
end
class Proc
  undef call
  undef to_proc
end
class NilClass
  undef to_s
end

# ---

class Zomg
end

Zomg                       # => Zom
class << Zomg
  attr_accessor :inspect
end
Zomg.inspect = "lolol"
Zomg                       # => lolol
raise zde
