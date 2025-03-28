# Some Party

[Some Party](https://www.someparty.ca) is a newsletter sharing the latest in independent Canadian rock'n'roll, curated more-or-less weekly by Adam White.

Each edition explores punk, garage, psych, and otherwise uncategorizable indie rock, drawing lines from proto to post and taking some weird diversions along the way.

## Installation

The Some Party website is built using [Middleman](http://middlemanapp.com/), a static site generator built on Ruby. Middleman uses the RubyGems package manager for installation. For instructions on installing and running Middleman in a development environment visit [Middleman at GitHub](https://github.com/middleman/middleman) for instructions.

With Middleman and Ruby installed, to run a server locally enter the directory into which you've checked out Some Party and run

```
bundle exec middleman server
```

The site will then be available to preview at: http://localhost:4567/

To build the project for the web run

```
bundle exec middleman build
```

This will compile the static site into the build directory, which can then be pushed up to Github Pages.

## Sending Newsletters

### Create email HTML

Generate an email-formatted version of the site with:

```
MEDIUM=email bundle exec middleman build
```

This will create a version of the static site with email-friendly HTML and inline CSS, deposited into the dispatch directory.

### Fetch recipients

The local copy of recipients.json should be empty from the previous send. Pull the latest subscribers down from S3 with:

```
ruby fetch_subscribers.rb
```

### Send a test email

Ensure the tmp/test.json file has some recipient data, such as:

```
[
  {
    "uuid": "ABCDEFG-12345",
    "date_subscribed": "2023-12-08T20:26:06Z",
    "email": "adam@someparty.ca",
    "timestamp_subscribed": "0.1702067166e10"
  }
]
```

Send the email to the test subscriber, noting the exact file name of the generated article HTML (in this example, "2025-03-26-luna-fm") you wish to send:

```
ruby send.rb -p 2025-03-26-luna-fm -r test.json
```

### Send to all recipients

If the test looks good, send the email to the actual subscribers:

```
ruby send.rb -p 2025-03-26-luna-fm -r recipients.json
```

## Bug Reports

Github Issues are used for managing bug reports and feature requests for Some Party. If you run into issues, please search the issues and submit new problems: https://github.com/someparty/someparty/issues

## License

The Some Party source code is licensed under the MIT license.

All site content is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).
