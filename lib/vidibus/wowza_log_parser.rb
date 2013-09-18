module Vidibus
  class WowzaLogParser
    VERSION = '0.1.0'
    FIELDS = 'date time  tz  x-event x-category  x-severity  x-status  x-ctx x-comment x-vhost x-app x-appinst x-duration  s-ip  s-port  s-uri c-ip  c-proto c-referrer  c-user-agent  c-client-id cs-bytes  sc-bytes  x-stream-id x-spos  cs-stream-bytes sc-stream-bytes x-sname x-sname-query x-file-name x-file-ext  x-file-size x-file-length x-suri  x-suri-stem x-suri-query  cs-uri-stem cs-uri-query'
    MATCHERS = {
      '_field' => '([^\s]+)',
      '_tab' => '\t',
      '_space' => '\s+',
      'x-status' => '((?:\d+|-))',
      'x-comment' => '(.+)',
      'x-duration' => '(\d+\.\d+)',
      'c-proto' => '([^\s]+(?:\s\(.+\))?)',
      'c-user-agent' => '(.+?)',
      'c-client-id' => '((?:\d+|-))'
    }

    def fields
      @fields ||= FIELDS
    end

    def fields=(input)
      @fields_list = nil
      @fields = input
    end

    def matchers
      @matchers ||= MATCHERS
    end

    def matchers=(input)
      @fields_list = nil
      @matchers = input
    end

    def parse(input, options = {})
      unless input
        raise(ArgumentError, 'No input given')
      end
      if File.file?(input)
        input = File.read(input)
      end
      filter = options[:filter]
      output = []
      input.split(/\n+/).each do |line|
        next if filter && !line.match(filter)
        values = nil
        if matchers['_tab']
          values = fields.split(matchers['_tab'])
        end
        unless values && values.count == keys.count
          if match = line.match(regex)
            values = match.to_a[1..-1]
          else
            values = nil
          end
        end
        if values
          output << Hash[[keys, values].transpose].reject {|k,v| v == '-'}
        end
      end
      output
    end

    private

    def regex
      regex_parts = []
      keys.each do |field|
        regex = matchers[field] || matchers['_field']
        regex_parts << regex
      end
      regex = '^' + regex_parts.join(matchers['_space']) + '$'
    end

    def keys
      @keys ||= fields.split(Regexp.new(matchers['_space']))
    end
  end
end
