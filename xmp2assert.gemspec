#! /your/favourite/path/to/gem
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

# :HACK: avoid namespace pollution
path            = File.expand_path 'lib/xmp2assert/version.rb', __dir__
content         = File.read path
version         = Module.new.module_eval <<-'end'
  XMP2Assert = Module.new
  eval content, binding, path
end

Gem::Specification.new do |spec|
  spec.name          = 'xmp2assert'
  spec.version       = version
  spec.author        = 'Urabe, Shyouhei'
  spec.email         = 'shyouhei@ruby-lang.org'
  spec.summary       = 'auto-generate assertions from `# =>` comments'
  spec.description   = <<-'end'.gsub(/\s+/, ' ').strip
    In  ruby we  use `#  =>`  as a  comment  marker that  mean the  immediately
    adjacent  expression's expected  value.  There  are gems  like xmpfilter  /
    seening_is_believing, which are  to generate such comments.   They are very
    useful.  But so far  we lack feature that does vice-versa;  to check if the
    comment is actually the output of the expression.

    This is the library that does it.
  end
  spec.homepage      = 'https://github.com/shyouhei/xmp2assert'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r'^(test|spec|features|samples)/')
  }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r'^exe/') { |f| File.basename(f) }

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'github-markup'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rcodetools'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'seeing_is_believing'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
  spec.add_runtime_dependency     'ruby-uuid'
  spec.add_runtime_dependency     'test-unit', '>= 3'
  spec.required_ruby_version =    '>= 2.2'
end
