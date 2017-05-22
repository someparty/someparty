![Some Party](https://www.someparty.ca/images/logo_wide.svg)

# Some Party

A weekly newsletter on independent Canadian rock'n'roll, curated every Sunday evening by Adam White of Punknews.org. A sober second thought on new music, cool records, and the people making their own culture.

## Installation

The Some Party website is built using [Middleman](http://middlemanapp.com/), a static site generator built on Ruby. Middleman uses the RubyGems package manager for installation. For instructions on installing and running Middleman in a development environment visit [Middleman at GitHub](https://github.com/middleman/middleman) for instructions.

With Middleman and Ruby installed, to run a server locally enter the directory into which you've checked out Some Party and run

```
middleman server
```

The site will then be available at: http://localhost:4567/

To build the project run

```
middleman build
```

## Functional css

Some Party uses the [Tachyons](http://tachyons.io/) functional CSS framework. A locally committed version of Tachyons 4.6.1 is located in the source/stylesheets directory.

All Some Party articles are written in Markdown and parsed using the [Redcarpet](https://github.com/vmg/redcarpet) Markdown parsing library. The file someparty_renderer.rb contains overrides for the default Redcarpet / Middleman implementation to insert Tachyons-style CSS tags the generated HTML tags.

## Bug Reports

Github Issues are used for managing bug reports and feature requests for Some Party. If you run into issues, please search the issues and submit new problems: https://github.com/someparty/someparty/issues

## License

The Some Party source code is licensed under the MIT license.

All site content is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).