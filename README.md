# Vidibus::WowzaLogParser [![Build Status](https://travis-ci.org/vidibus/vidibus-wowza_log_parser.png)](https://travis-ci.org/vidibus/vidibus-wowza_log_parser)

A simple parser for Wowza access logs.

This gem is part of [Vidibus](http://vidibus.org), an open source toolset for building distributed (video) applications.


## Installation

Add `gem 'vidibus-wowza_log_parser'` to the Gemfile of your application. Then call `bundle install` on your console.


## Usage

To parse an access log, provide the path to a file or just the log lines:

```ruby
parser = Vidibus::WowzaLogParser.new
parser.parse('path/to/access.log')
# => [{}, {}, ...]

parser.parse('a log line')
# => [{}, {}, ...]
```

The parser will use Wowza's default fields to match the logs:

```
date time  tz  x-event x-category  x-severity  x-status  x-ctx x-comment x-vhost x-app x-appinst x-duration  s-ip  s-port  s-uri c-ip  c-proto c-referrer  c-user-agent  c-client-id cs-bytes  sc-bytes  x-stream-id x-spos  cs-stream-bytes sc-stream-bytes x-sname x-sname-query x-file-name x-file-ext  x-file-size x-file-length x-suri  x-suri-stem x-suri-query  cs-uri-stem cs-uri-query
```

Thus each result hash will include all fields with values while omitting the blank entries:

```ruby
  line = '2013-09-17  00:00:04  CEST  comment server  WARN  200 - LiveMediaStreamReceiver.doWatchdog: streamTimeout - - - 382109.883  - - - - - - - - - - - - - - - - - - - - - - - - -'
  parser = Vidibus::WowzaLogParser.new
  parser.parse(line)
  # => {
  #  'date' => '2013-09-17',
  #  'time' => '00:00:04',
  #  'tz' => 'CEST',
  #  'x-event' => 'comment',
  #  'x-category' => 'server',
  #  'x-severity' => 'WARN',
  #  'x-status' => '200',
  #  'x-comment' => 'LiveMediaStreamReceiver.doWatchdog: streamTimeout',
  #  'x-duration' => '382109.883'
  #}
```

If you have a different log format or want to group values, you may provide custom fields and matchers:

```ruby
  line = '2013-09-17  00:00:04  CEST  comment server  WARN  200 - LiveMediaStreamReceiver.doWatchdog: streamTimeout - - - 382109.883  - - - - - - - - - - - - - - - - - - - - - - - - -'
  parser = Vidibus::WowzaLogParser.new
  parser.fields = 'datetime content'
  parser.matchers['datetime'] = '(.+ CEST)'
  parser.matchers['content'] = '(.+)'
  parser.parse(line)
  # => {
  #  'datetime' => '2013-09-17  00:00:04  CEST',
  #  'content' => 'comment server  WARN  200 - LiveMediaStreamReceiver.doWatchdog: streamTimeout - - - 382109.883  - - - - - - - - - - - - - - - - - - - - - - - - -',
  #}
```


## Testing

To test your gem, call `rspec spec` on your console.
To imitate the way Travis tests your gem, perform `bundle exec rspec spec --format progress`.


## Copyright

&copy; 2013 punkrats. See LICENSE for details.
