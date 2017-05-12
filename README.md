You might have experience of encountering something like

```ruby:
1 + 2 # => 3
```

What is this comment?  This means when you evaluate `1 + 2`, the result is `3`.

This kind of comments are handy.  But one thing remains uncertain is: do they actually are right?

There are tools like [JoshCheek/seeing_is_believing] who generates such comments, but so far I have never seen a tool that does vice versa.

So I made this library.

## Basic usage as script

I made a fairly simple script named xmpcheck.rb.  Run that with a list of ruby script.

```sh
% bundle exec xmpcheck.rb file file file ...
```

It automatically checks for those comments and see if they are right.

## Library usage

Really sorry but we have no dedicated document than the YARD. Pro-tip: look at `XMP2Assert::Assertions`

## Languages understood by this library

- Everything but comments are passed verbatimly to underlying ruby interpreter.  We don't go deep in this area.
- There are currently four kinds of special comments that make sense.  All other comments are verbatimly passed to the underlying ruby interpreter (and then, silently ignored there).
- The most basic `=>` comment describes the value of an expression that is immediately leading the comment.

    ```ruby
	1 + 2 # => 3
	```

- An exceptions is described by a `~>` comment.  Because exceptions are kind of control flows, the thing the comment describes tends to be a statement, not expression-in-general.

    ```ruby
	raise "foo" # ~> foo
	```

- Outputs are also described.  There are two kinds of IO comments; `>>` for stdout and `!>` for stderr.  Note however that They are checked buffered, not line-by-line.

    ```ruby
	puts "foo" # >> foo
	```

- Comments are not mixed i.e. you can't describe stderr and stdout in a same line.  You have to separate them in dedicated lines.

    ```ruby
	STDOUT.puts "foo"; STDERR.puts "bar"
	# => nil
	# >> foo
	# ~> bar
	```

- The "expression that is immediately leading the comment" is not that obvious than you think.  For instance,

    ```ruby
	<<END + <<END.lines.length
	foo
	END
	#{<<END}
	bar
	END
	END
	# => ...?
	```

	This is a valid ruby script but extraordinary complicated.  What is the expression that the comment at the last line describes?  It is strongly advised that you should not write such things and go concise.

	Understanding of non-comment ruby expression is best effort; done using heuritics.

## What if I want to contribute?

Before proceeding any further, you have to take this action:

1. Clone this project.
2. Run the test at least once.
3. Read through the [style guide].
4. Create your own topic branch and do your stuff.
5. Send us a pull request.

[JoshCheek/seeing_is_believing]: https://github.com/JoshCheek/seeing_is_believing
[style guide]: Styleguide.md
