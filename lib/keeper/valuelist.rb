module Keeper
  class Containers

    def initialize(name, options)
      super
      require 'net/https'
      require 'uri'
      @uri = URI.parse(options[:url])
      @username = options[:username]
      @password = options[:password]
      @connection = Net::HTTP.new( @uri.host, @uri.port )
      # from http://www.rubyinside.com/nethttp-cheat-sheet-2940.html
      @connection.use_ssl = true if @uri.scheme == "https"
      @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE

    end
    
    def categories
      @categories ||= values_of "list_categories", "/value"
    end
    def partners
      @partners ||= values_of "list_partner", "/value"
    end
    def roles
      @roles ||= values_of "list_roles"
    end
    def viewparts
      @viewparts ||= values_of("list_view_parts")
    end
    def xmlfields
      @xmlfields ||= values_of("list_xmlfields")
    end

    def get(path)
#      $stderr.puts "Get #{@uri.path} + #{path}"
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
      raise TypeError unless response['content-type'] =~ /xml/
      body = response.body
      if response['content-encoding'] == "gzip"
	require 'zlib'
	require 'stringio'
	# http://stackoverflow.com/questions/1361892/how-to-decompress-gzip-string-in-ruby
	body = Zlib::GzipReader.new(StringIO.new(body)).read
      end
      Nokogiri::XML body
    end

  private
    def values_of id, detail = nil
#      STDERR.puts "----------------------\nextract_values #{id}\n#-------------------"
      
      if detail
	result = []
      else
	result = {}
      end

      valuelist.xpath("//valuelist[@id='#{id}']/item#{detail}").each do |node|
	if detail
	  # node = <value>foo</value>
	  result << node.text
	else
	  # node = <item><value>...</value><property name='...'>...</property>
	  # with multiple properties
	  props = {}
#	  puts "Node #{node}"
#	  puts "Value #{node.xpath('./value').text}"
	  node.xpath("./property").each do |prop|
#	    puts "prop #{prop}"
#	    puts "name #{prop['name']}"
#	    puts "content #{prop.content}"
	    props[prop['name']] = prop.text
	  end
#	  puts "Props #{props.inspect}"
	  result[node.xpath("./value").text] = props
	end
      end
      raise RuntimeError if result.empty?
      result
    end

    def valuelist
      @valuelist ||= get "/valuelist"
      raise RuntimeError if @valuelist.nil?
      @valuelist
    end

  end
end
