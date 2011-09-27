require "dm-keeper-adapter"
require "nokogiri"

module Keeper
  class ContainerEntry
    attr_reader :name, :description, :size, :postmaster
    #
    # parse
    # <tr class="title">
    #   <td colspan="2"><b>product</b></td></tr>
    # <tr><td><b>Description:</b></td><td>Container for storing product definitions from NPP.</td></tr>
    # <tr><td><b>Documents:</b></td><td>#325</td></tr>
    # <tr><td><b>Update notification class: </b></td><td>null</td></tr>
    # <tr><td><b>Read-only: </b></td><td>false</td></tr>
    # <tr><td><b>Notification debug: </b></td><td>false</td></tr>
    # <tr><td><b>Notification postmaster: </b></td><td>tschmidt@suse.de</td></tr>
    #
    def initialize node
#      $stderr.puts "ContainerEntry(#{node})"
      @name = node.xpath("./td/b").text
      while node = node.next do # next <tr>
	break if node['class']
	key = value = nil
	node.children.each do |child| # iterate over <td>
	  if child.child.name == "b" # <td><b>
	    key = child.child.text
	  else
	    value = child.text
	  end
	  if key && value
	    case key
	    when "Description:": @description = value
	    when "Documents:": @size = value.to_i
	    when "Notification postmaster: ": @postmaster = value
	    end
	    key = value = nil
	  end
	end
      end
    end
    def to_s
      "#{@name}: #{@description}"
    end
  end
  class Container
    def initialize adapter
      @adapter = adapter
      @entries = []
      node = adapter.get "/info"
      node.xpath("//tr[@class='title']").each do |node|
	@entries << ContainerEntry.new(node)
      end
    end
    def each
      @entries.each { |e| yield e }
    end
  end
end
