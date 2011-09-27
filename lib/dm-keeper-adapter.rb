require 'rubygems'
require 'dm-core'
require 'dm-core/adapters/abstract_adapter'

require "dm-keeper-adapter/create"
require "dm-keeper-adapter/read"
require "dm-keeper-adapter/update"
require "dm-keeper-adapter/delete"
require "dm-keeper-adapter/misc"


module DataMapper
  class Property
    autoload :XML, "property/xml"
  end
end


module DataMapper::Adapters
  
  class KeeperAdapter < AbstractAdapter
    OSCRC_CREDENTIALS = "https://api.opensuse.org"

    def initialize(name, options)
      super
      require 'net/https'
      require 'uri'
      @uri = URI.parse(options[:url])
      @username = options[:username]
      @password = options[:password]
      unless @username && @password
	require 'inifile'
	oscrc = IniFile.new(File.join(ENV['HOME'], '.oscrc'))
        if oscrc.has_section?(OSCRC_CREDENTIALS)
          @username = oscrc[OSCRC_CREDENTIALS]['user']
          @password = oscrc[OSCRC_CREDENTIALS]['pass']
          raise "No .oscrc credentials for keeper.novell.com" unless @username && @password
        end
      end
      @connection = Net::HTTP.new( @uri.host, @uri.port )
      # from http://www.rubyinside.com/nethttp-cheat-sheet-2940.html
      @connection.use_ssl = true if @uri.scheme == "https"
      @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE

    end

    def get(path)
#      STDERR.puts "Get #{@uri.path} + #{path}"
      request = Net::HTTP::Get.new @uri.path + path
      request.basic_auth @username, @password
      response = @connection.request request
      raise ArgumentError unless response
      raise( RuntimeError, "Server returned #{response.code}" ) unless response.code.to_i == 200
#      $stderr.puts "#{response.inspect}"
#      response.each { |k,v| $stderr.puts "#{k}: #{v}" }
#      $stderr.puts "Encoding >#{response['content-encoding']}<"
      # check
      # content-type: text/xml;charset=UTF-8
      # content-encoding: gzip
      body = response.body
      if response['content-encoding'] == "gzip"
	require 'zlib'
	require 'stringio'
	# http://stackoverflow.com/questions/1361892/how-to-decompress-gzip-string-in-ruby
	body = Zlib::GzipReader.new(StringIO.new(body)).read
      end
      case response['content-type']
	when /xml/
	  Nokogiri::XML body
	when /html/
	  Nokogiri::HTML body
	else
	  raise TypeError, "Unknown content-type #{response['content-type']}"
      end
    end

  end
end
