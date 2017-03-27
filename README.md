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

## What if I want to contribute?

Before proceeding any further, you have to take this action:

1. Clone this project.
2. Run the test at least once.
3. Read through the [style guide].
4. Create your own topic branch and do your stuff.
5. Send us a pull request.

[JoshCheek/seeing_is_believing]: https://github.com/JoshCheek/seeing_is_believing
[style guide]: Styleguide.md
