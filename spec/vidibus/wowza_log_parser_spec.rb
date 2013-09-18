require 'spec_helper'

describe Vidibus::WowzaLogParser do
  let(:subject) { Vidibus::WowzaLogParser.new }
  let(:log_path) { 'spec/support/access.log' }

  describe '::FIELDS' do
    it 'should match Wowza defaults' do
      Vidibus::WowzaLogParser::FIELDS.should eq('date time  tz  x-event x-category  x-severity  x-status  x-ctx x-comment x-vhost x-app x-appinst x-duration  s-ip  s-port  s-uri c-ip  c-proto c-referrer  c-user-agent  c-client-id cs-bytes  sc-bytes  x-stream-id x-spos  cs-stream-bytes sc-stream-bytes x-sname x-sname-query x-file-name x-file-ext  x-file-size x-file-length x-suri  x-suri-stem x-suri-query  cs-uri-stem cs-uri-query')
    end
  end

  describe '#fields' do
    it 'should return ::FIELDS by default' do
      subject.fields.should eq(Vidibus::WowzaLogParser::FIELDS)
    end

    it 'should be overridable' do
      subject.fields = 'whatever'
      subject.fields.should eq('whatever')
    end
  end

  describe '#matchers' do
    it 'should return ::MATCHERS by default' do
      subject.matchers.should eq(Vidibus::WowzaLogParser::MATCHERS)
    end

    it 'should be overridable' do
      subject.matchers['some'] = 'whatever'
      subject.matchers['some'].should eq('whatever')
    end
  end

  describe '#parse' do
    it 'should take file path input' do
      mock(File).read(log_path) { 'something' }
      subject.parse(log_path)
    end

    it 'should take string input' do
      dont_allow(File).read('whatever')
      subject.parse('whatever')
    end

    it 'should raise an error if no input is given' do
      expect { subject.parse(nil) }.to raise_error(ArgumentError)
    end

    it 'should work on a server comment' do
      line = '2013-09-17  00:00:04  CEST  comment server  WARN  200 - LiveMediaStreamReceiver.doWatchdog: streamTimeout - - - 382109.883  - - - - - - - - - - - - - - - - - - - - - - - - -'
      values = {
        'date' => '2013-09-17',
        'time' => '00:00:04',
        'tz' => 'CEST',
        'x-event' => 'comment',
        'x-category' => 'server',
        'x-severity' => 'WARN',
        'x-status' => '200',
        'x-comment' => 'LiveMediaStreamReceiver.doWatchdog: streamTimeout',
        'x-duration' => '382109.883'
      }
      subject.parse(line).should eq([values])
    end

    it 'should work on a client request from flash' do
      line = '2013-09-17  22:29:06  CEST  destroy stream  INFO  200 rtmp://server.host:1935/whatever/_definst_/15  - _defaultVHost_  whatever  _definst_ 311.903 [any] 1935  rtmp://server.host/whatever?aaa&5aef823781cda67213ac2c4c2f92fffe 88.100.151.103  rtmp  http://client.host/assets/player.swf  WIN 11,8,800,168  1655135296  3837  8344  1 - 0 0 rtmp://server.host:1935/whatever/_definst_/15  - - - - - rtmp://server.host/whatever/rtmp://server.host:1935/whatever/_definst_/15  rtmp://server.host/whatever/rtmp://server.host:1935/whatever/_definst_/15  - rtmp://server.host/whatever aaa&5aef823781cda67213ac2c4c2f92fffe'
      values = {
        'date' => '2013-09-17',
        'time' => '22:29:06',
        'tz' => 'CEST',
        'x-event' => 'destroy',
        'x-category' => 'stream',
        'x-severity' => 'INFO',
        'x-status' => '200',
        'x-ctx' => 'rtmp://server.host:1935/whatever/_definst_/15',
        'x-vhost' => '_defaultVHost_',
        'x-app' => 'whatever',
        'x-appinst' => '_definst_',
        'x-duration' => '311.903',
        's-ip' => '[any]',
        's-port' => '1935',
        's-uri' => 'rtmp://server.host/whatever?aaa&5aef823781cda67213ac2c4c2f92fffe',
        'c-ip' => '88.100.151.103',
        'c-proto' => 'rtmp',
        'c-referrer' => 'http://client.host/assets/player.swf',
        'c-user-agent' => 'WIN 11,8,800,168',
        'c-client-id' => '1655135296',
        'cs-bytes' => '3837',
        'sc-bytes' => '8344',
        'x-stream-id' => '1',
        'cs-stream-bytes' => '0',
        'sc-stream-bytes' => '0',
        'x-sname' => 'rtmp://server.host:1935/whatever/_definst_/15',
        'x-suri' => 'rtmp://server.host/whatever/rtmp://server.host:1935/whatever/_definst_/15',
        'x-suri-stem' => 'rtmp://server.host/whatever/rtmp://server.host:1935/whatever/_definst_/15',
        'cs-uri-stem' => 'rtmp://server.host/whatever',
        'cs-uri-query' => 'aaa&5aef823781cda67213ac2c4c2f92fffe'
      }
      subject.parse(line).should eq([values])
    end

    it 'should work on a client request from iOS' do
      line = '2013-09-17  21:51:53  CEST  destroy stream  INFO  200 rtmp://server.host:1935/whatever/_definst_/15~max  - _defaultVHost_  whatever  _definst_ 34.061  server.host 1935  http://server.host:1935/whatever/15~max/media_575.ts?wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F 217.226.61.42 http (cupertino)  - AppleCoreMedia/1.0.0.10B329 (iPad; U; CPU OS 6_1_3 like Mac OS X; de_de)  1516262997  0 2316598 2731  9211062 0 2315784 15~max  wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F  - - - - http://server.host:1935/whatever/15~max/media_575.ts?wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F http://server.host:1935/whatever/15~max/media_575.ts  wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F  http://server.host:1935/whatever/15~max/media_575.ts  wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F'
      values = {
        'date' => '2013-09-17',
        'time' => '21:51:53',
        'tz' => 'CEST',
        'x-event' => 'destroy',
        'x-category' => 'stream',
        'x-severity' => 'INFO',
        'x-status' => '200',
        'x-ctx' => 'rtmp://server.host:1935/whatever/_definst_/15~max',
        'x-vhost' => '_defaultVHost_',
        'x-app' => 'whatever',
        'x-appinst' => '_definst_',
        'x-duration' => '34.061',
        's-ip' => 'server.host',
        's-port' => '1935',
        's-uri' => 'http://server.host:1935/whatever/15~max/media_575.ts?wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F',
        'c-ip' => '217.226.61.42',
        'c-proto' => 'http (cupertino)',
        'c-user-agent' => 'AppleCoreMedia/1.0.0.10B329 (iPad; U; CPU OS 6_1_3 like Mac OS X; de_de)',
        'c-client-id' => '1516262997',
        'cs-bytes' => '0',
        'sc-bytes' => '2316598',
        'x-stream-id' => '2731',
        'x-spos' => '9211062',
        'cs-stream-bytes' => '0',
        'sc-stream-bytes' => '2315784',
        'x-sname' => '15~max',
        'x-sname-query' => 'wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F',
        'x-suri' => 'http://server.host:1935/whatever/15~max/media_575.ts?wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F',
        'x-suri-stem' => 'http://server.host:1935/whatever/15~max/media_575.ts',
        'x-suri-query' => 'wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F',
        'cs-uri-stem' => 'http://server.host:1935/whatever/15~max/media_575.ts',
        'cs-uri-query' => 'wowzasessionid=1516262997&realm=aaa&session=5437d51de4903971b427512e242ad4fe%2F'
      }
      subject.parse(line).should eq([values])
    end

    it 'should return output from multiple lines' do
      subject.parse(log_path).count eq(100)
    end

    context 'with filter' do
      it 'should return matching lines only' do
        subject.parse(log_path, :filter => /comment\s+server/).count eq(1)
      end
    end

    context 'with custom fields and matchers' do
      it 'should work' do
        line = '2013-09-17  00:00:04  CEST  comment server  WARN  200 - LiveMediaStreamReceiver.doWatchdog: streamTimeout - - - 382109.883  - - - - - - - - - - - - - - - - - - - - - - - - -'
        values = {
          'datetime' => '2013-09-17  00:00:04  CEST',
          'content' => 'comment server  WARN  200 - LiveMediaStreamReceiver.doWatchdog: streamTimeout - - - 382109.883  - - - - - - - - - - - - - - - - - - - - - - - - -',
        }
        subject.fields = 'datetime content'
        subject.matchers['datetime'] = '(.+ CEST)'
        subject.matchers['content'] = '(.+)'
        subject.parse(line).should eq([values])
      end
    end
  end
end
