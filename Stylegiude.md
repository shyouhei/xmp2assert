# Ruby style guide to use in this project

I'm not a language nazi here. This guide is for you to ease your _documenting_, not to cramp your coding. This guide tells not so much about the ruby code themselves, rather focusing on comments.

## Terminology

The key words "_MUST_", "_MUST NOT_", "_REQUIRED_", "_SHALL_", "_SHALL NOT_", "_SHOULD_", "_SHOULD NOT_", "_RECOMMENDED_", "_MAY_", and "_OPTIONAL_" in this document are to be interpreted as described in [RFC 2119].

## Use of characters in a file

### DO

  - Any files under this project _MUST_ strictly be written using code points described in Unicode's "C0 Controls and Basic Latin" [1] only, and _MUST_ then be encoded using [RFC 3629].
      - This is for maximum portability.
      - You can't represent your name in that code range? Me too.
  - A file _SHOULD_ end with a U+000A.

### DON'T

  - So-called "control characters" (U+0000 to U+001F and U+007F) _SHOULD_ generally be avoided. U+000A is the only exception to this principle.
  - Especially, U+0009 and U+000D _MUST NOT_ appear verbatimly in a source code. They _MUST_ be escaped as `\t` and `\r` respectively when needed.
      - Whenever you cannot escape them, it indicates a serious design flaw.
  - U+000A _MUST NOT_ appear right after U+0020.
  - U+FEFF _MUST NOT_ appear at the very beginning of a file.

## Use of languages in a file

### DO
  - Comments _MUST_ be written in modern English.
  - One or more spaces _MUST_ be placed between sentences in a comment. You _MAY_ put more than one spaces.
      - There are discussions as to how much spaces needed between sentences [2]. I use single spacing in this guide because that is modern, but honestly I'm used to have two spaces, because that's the default of Emacs.
  - Identifiers (method names etc.) _MUST_ be named in valid modern English words, without shortening.
      - This doesn't mean you should name your class Emma or Sophia.
      - Local variables in a sufficiently short scope _MAY_ be named in one character like `i`, `j`, `k`. This conventional usage of variable names is a tradition to be honored.
  - When you name something, that name _SHOULD_ be elegant, concise, succinct, and (most importantly) to the point.

## Comments

### DO

  - Write comments in [markdown], with [YARD]'s tag extensions, and let YARD parse that.
      - See the YARD section below.

### DON'T

  - Comments _SHOULD NOT_ be longer than 80 characters length.
      - I don't hesitate longer ruby lines but I do hesitate long comments. That should indicate a over-commenting. Try avoiding too much comments.
      - Long comments in a source code _SHOULD_ be line-wrapped.
  - Don't waste your time writing comments to describe bad codes; rather have time to make the code better.

## YARD

  - `@param`, which is the most frequently used, _SHOULD_ be done like this:

    ```
    # @param foo [Foo] description of foo.
    # @param bar [Bar] description of bar.
    ```

    Pro-tip here is that description _SHOULD_ start with lower character. YARD capitalizes that when necessary.

    Also trailing periods are _RECOMMENDED_.

  - Ruby2's explicit named parameters are preferred. But if you decide to take good-old hash-taking strategy instead, `@option` is done like this:

    ```
    # @param  opt [Hash]      description of opt.
    # @option opt [Foo]  :foo description of foo.
    # @option opt [Bar]  :bar description of bar.
    ```

    I recommend you to align things vertically for aesthetic reasons. No ugly comments are read seriously.

  - `@return` is like this:

    ```
    # @return [Foo] description when it returns Foo.
    # @return [Bar] description when it returns Bar.
    ```

    Return's descriptions _SHOULD_ also start with lower character. It is worth noting that you _SHOULD_ also provide one for `attr_` family.

    ```
    attr_reader :foo # @return [Foo] description of foo
    ```

  - When your method takes a block that _SHOULD_ come with `@yieldparam` and `@yieldreturn`. `@yieldreturn` _MAY_ be omitted when the block-evaluated value does not matter but that sounds something is wrong with API design.

    ```
    # @yieldparam  foo [Foo] description of foo
    # @yieldreturn     [Bar] description of value to be returned from the block
    ```

  - Exceptions are, of course to be documented. But in practice it often is pretty difficult to list up all possible exceptions that can happen inside, especially when your method calls 3rd-party library or does network IO. So don't try to be perfect. Just write what you know. Less is better than nothing.

    ```
    # @raise [Foo] description when Foo is raised.
    ```
## Identifiers

### DO

  - Constants _SHOULD_ be named in UpperCamelCase.
  - Everything except constants _SHOULD_ be named in snake_case.

### DON'T

  - Bare numeric literals _SHOULD NOT_ be used as magic numbers. Assign them to appropriate variables / constants and use them instead.
  - New global variables _MUST NOT_ be introduced.
      - Predefined global variables _SHOULD NOT_ be (re-)assigned. There tends to be other ways without doing so.
  - A bang method _MUST NOT_ be created without its bang-less counterpart.

## File-scope Structures

  - A ruby file is _RECOMMENDED_ to be written like this:

    ```ruby
    #! shebang line if this is a non-library
    # -*- Emacs-compatible mode line -*-
    # -*- other magic comments -*-
    # -*- other magic comments (write necessary times)-*-

    # Copyright notices
    # ``Permission is hereby granted, ...''

    require lines
    require_relative lines

    # class/module description in YARD
    class Foo::Bar < Baz
      using   Something # if any
      prepend Something # if any
      include Something # if any
      extend  Something # if any

      # method description in YARD
      def self.method argv...
        ...
      end

      # attribute description in YARD
      attr_reader :something
      attr_reader :something_else # description can be here if short enough

      # method description in YARD
      def method argv...
        ...
      end

      private

      def private_method
        # private methods can omit YARD comments
      end
    end
    ```

      - This recommended file structure is known to be OK to feed to YARD's parser.
  - You can ignore this recommendation on exceptional situations, but a good reason should come with that. I strongly encourage you to write why to that part's comment.

### DO

  - Shebang line would automatically be modified appropriately on installation, by the rubygems infrastructure. So don't get nervous about what to write; just write something. I normally put `#! /your/favourite/path/to/ruby` or something like that, to indicate that the line content is not something serious.
  - This is a less-known fact but there are two kinds of magic comments; those which are Emacs compatible, and those aren't. In order to interface with the editor, those compatible ones _MUST_ be placed where it looks at. On the other hand, incompatible ones _MUST NOT_ be placed there, in order to avoid harassing other processes. Ruby allows magic comments on liberal places.

    This means you _SHOULD_ separate magic comments into more than two. As of writing this document, following magic comments are known to be Emacs incompatible:
    - `frozen_string_literal`
    - `warn_indent`
    - `warn_past_scope`
  - Copyright notices _SHALL_ be placed in every files, unless technically impossible. People tend to copy and paste your code without using their brain. You must be explicit.
  - All dependencies _SHOULD_ be listed explicitly by `require`-ing them all, so that your file can be used stand-alone. In other words, even if your file is a part of your library, that file, alone, should be `require`-able without extra hustle.

### DON'T

  - In order to prevent unnecessary reopen of classes, you _SHOULD NOT_ nest class declarations like `class Foo; class Bar`. Use `class Foo::Bar` instead for that example. If you do want to touch `Foo` as well as `Bar`, consider separate them in distinct files.
  - Class singleton methods _SHOULD_ be defined using `def self.foo`, to prevent nested classes. If you want to do complex manipulations on the metaclass you can, but consider to refactor your code before doing so.
  - `protected` _MUST NOT_ be used.

## Ruby Control Flows

### DON'T

  - No `else` _MUST_ come with `unless`.
  - No `while` _MUST_ come with `begin`.
  - No `=begin` (thus no `=end`) _MUST_ appear in a source code.
  - No `BEGIN` _MUST_ exist.
  - No `END` _MUST_ exist.
  - Postfix `rescue` modifiers _SHOULD_ be avoided whenever possible. Reasons behind this:
[Feature #6739] [Feature #10042]
  - Postfix modifiers _SHOULD NOT_ be "nested" like `foo if bar while baz`. That might work, but never be understandable by mortals.
  - Ternary operators _SHOULD NOT_ be "nested" like `q ? w : e ? r : t ? y : u`. That might work, but never be understandable by mortals.
  - I see no need to use semicolons (`;`) except when you trick YARD parser.

### DO

  - Indent using 2 spaces. Neither 4 nor 3.
  - I prefer writing `then`.
  - Parens _MAY_ be omitted where you can.
      - My style is extremely paren-free. Try `git grep '[(]'` and see most occurrences are inside of comments.

        However that doesn't mean you _can't_ use them. My way is that when you can omit parens you do. Ruby is powerful so for most cases can. But there are several situations where you can't. Don't hesitate then.

  - I like what I call a case-else, which is a `case` statement that only has one `when` and optionally one `else`.

    ```ruby
    case expr when foo then
      # then
    else
      # else
    end
    ```

    This can be seen as a "smarter" `if` in some sense. The position of `when` emphasizes this is not a multiple branch.

    - When you do need multiple branches, you do ordinal `case` in this indentation:

      ```ruby
      case expr
      when foo then
        # foo
      when bar then
        # bar
      when baz then
        # baz
      else
        # otherwise
      end
      ```

  - I sometimes use heredocs this way:

    ```ruby
    printf <<~'end', 1, 2, 3
      foo %d bar %d baz %d
    end
    ```

    Feel what's happening. When it takes a block things gets more complex:

    ```ruby
    OptionParser.new do |this|
      this.on '-f', '--foo', <<~begin do
        description of --foo
        can go multiple lines
      begin
        # dealing with --foo
      end
    end
    ```

  - When line-wrapping a "fluent" long method chain, I prefer using backslash, newline, space, then dot. Backslashes can in fact be omitted grammar-wise, but I prefer placing them because a dot at a beginning of a line is almost impossible to find at sight.

    ```ruby
    complex_expression                 \
      .to_enum(:something)             \
      .lazy                            \
      .filter       {|i| i.something } \
      .slice_before {|i| i.something } \
      .map          {|a| a.something } \
      .take_while   {|a| a.something } \
      .uniq
    ```

      - You might want to consider refactoring before writing this.

## Misc

### DO

  - All ruby scripts _SHOULD_ pass `ruby -w`.
  - All ruby scripts _SHOULD_ pass `rake yard`.

### DON'T

  - Don't take `rake rubocop` as a canon.

[RFC 2119]:https://tools.ietf.org/html/rfc2119
[RFC 3629]: https://tools.ietf.org/html/rfc3629
[markdown]: http://commonmark.org
[YARD]: http://yardoc.org
[1]: http://unicode.org/charts/PDF/U0000.pdf
[2]: https://en.wikipedia.org/wiki/Sentence_spacing
[Feature #6739]: https://bugs.ruby-lang.org/issues/6739
[Feature #10042]: https://bugs.ruby-lang.org/issues/10042
