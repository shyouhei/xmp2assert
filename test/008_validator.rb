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

require_relative 'test_helper'
require 'xmp2assert/validator'

class TC008_Validator < Test::Unit::TestCase
  data({
    "1"              => ["1", true],
    "lines"          => ["1;1", true],
    "paren0"         => ["func(1)", true],
    "paren1"         => ["func(1", false],
    "paren2"         => ["1)", false],
    "mixed"          => ["[(])", false],
    "do}"            => ["1.times do }", false],
    "{end"           => ["1.times { end", false],
    "if"             => ["if true", false],
    "if then"        => ["if true then", false],
    "if then end"    => ["if true then 1 end", true],
    "heredoc"        => ["<<END\n1\nEND", true],
    "heredoc nested" => [<<-'end', true],
      <<-'END'
        #{<<-"__END__"}
          1
        __END__
      END
    end
  })

  test ".valid?" do |(expr, expected)|
    assert_equal(expected, XMP2Assert::Validator.valid?(expr))
  end
end
