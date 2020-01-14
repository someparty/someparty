# Some Party

Some Party is a newsletter sharing the latest in independent Canadian rock'n'roll, curated weekly by Adam White. 

Each edition explores punk, garage, psych, and otherwise uncategorizable indie rock, drawing lines from proto to post and taking some weird diversions along the way.

## Installation

The Some Party website is built using [Middleman](http://middlemanapp.com/), a static site generator built on Ruby. Middleman uses the RubyGems package manager for installation. For instructions on installing and running Middleman in a development environment visit [Middleman at GitHub](https://github.com/middleman/middleman) for instructions.

With Middleman and Ruby installed, to run a server locally enter the directory into which you've checked out Some Party and run

```
middleman server
```

The site will then be available at: http://localhost:4567/

To build the project for the web run

```
middleman build
```

To run the project with simplified markup and no CSS, which is best used when copied into the mailing list email body, use:

```
MEDIUM='email' middleman server
```

You can then navigate to an individual article and copy the markup.

## Functional css

On the web, Some Party uses the [Tachyons](http://tachyons.io/) functional CSS framework. The included CSS is based on a subset of Tachyons 4.6.1 (only the tags needed, nothing more).

All Some Party articles are written in Markdown and parsed using the [Redcarpet](https://github.com/vmg/redcarpet) Markdown parsing library. The file someparty_web_renderer.rb contains overrides for the default Redcarpet / Middleman implementation to insert Tachyons-style CSS tags the generated HTML tags.

## Bug Reports

Github Issues are used for managing bug reports and feature requests for Some Party. If you run into issues, please search the issues and submit new problems: https://github.com/someparty/someparty/issues

## License

The Some Party source code is licensed under the MIT license.

All site content is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
