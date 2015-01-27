#
# dm-keeper-adapter/read.rb
#
# Read/Query operations - A DataMapper adapter for FATE/features.opensuse.org
#
#--
# Copyright (c) 2011 SUSE LINUX Products GmbH
#
# Author: Klaus Kämpf <kkaempf@suse.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'cgi'

module DataMapper::Adapters
  class KeeperAdapter < AbstractAdapter
    require 'nokogiri'
    def read(query)
      records_for(query)
    end

  private
    # taken from https://github.com/whoahbot/dm-redis-adapter/
    
    def xpath_for(model, conditions)
      #
      # Handle Model.all
      #
      xpath = ""
      xpathmap = model.xpathmap rescue { }
      STDERR.puts "xpath_for(#{model},#{conditions})"
      conditions.operands.each do |operand|
        unless xpath.empty?
          case conditions
          when DataMapper::Query::Conditions::AndOperation
            xpath << " and "
          when DataMapper::Query::Conditions::OrOperation
            xpath << " or "
          else
            puts "*** Condition #{conditions}"
          end
        end
        subject = operand.subject
        value =  operand.value
        name = xpathmap[subject.name] || subject.name.to_s
        last = nil
        if name.include? '@'
          elements = name.split('/')
          last = elements.pop
          name = elements.join('/')
        end
        case operand
        when DataMapper::Query::Conditions::EqualToComparison
          if last
            if name.nil? || name.empty?
              xpath << "#{last}='#{value}'"
            else
              xpath << "#{name}[#{last}='#{value}']"
            end
          else
            xpath << "#{name}='#{value}'"
          end
          #          when DataMapper::Query::Conditions::LikeComparison
          #          when DataMapper::Query::Conditions::OrOperation
          #          when DataMapper::Query::Conditions::NotOperation
        else
          puts "*** Operand #{operand.inspect}"
        end
      end
      xpath
    end

    ##
    # Retrieves records for a particular model.
    #
    # @param [DataMapper::Query] query
    #   The query used to locate the resources
    #
    # @return [Array]
    #   An array of hashes of all of the records for a particular model
    #
    # typical queries
    #
    # ?query=/feature[
    #   productcontext[
    #    not (status[done or rejected or duplicate or unconfirmed])
    #  ]
    #  and
    #  actor[
    #    (person/userid='kkaempf@suse.com' or person/email='kkaempf@suse.com' or person/fullname='kkaempf@suse.com')
    #    and
    #    role='projectmanager'
    #  ]
    # ]
    #
    #  "/#{container}[actor/role='infoprovider']
    #
    # query=/feature[title='Foo%20bar%20baz']
    #
    # query=/feature[contains(title,'Foo')]
    # query=/feature[contains(title,'Foo')]/title
    # query=/feature[contains(title,'Foo')]/@k:id
    #
    def records_for(query)
      STDERR.puts "records_for(#{query.inspect})"
      container = query.model.to_s.downcase
      if query.conditions.nil?
        xpath = ""
      else
        STDERR.puts "conditions(#{query.conditions.inspect})"
        #
        # Check if it's a Model.get
        #
        if query.conditions.operands.size == 1
          operand = query.conditions.operands.first
          subject = operand.subject
          STDERR.puts "Single operand #{operand.inspect}, subject #{subject.inspect}"
          STDERR.puts "Model key #{query.model.key.inspect}"
          if (operand.is_a?(DataMapper::Query::Conditions::EqualToComparison) &&
              query.model.key.first.name == subject.name)
            xpath = "/#{operand.value}"
          end
        end
        xpath = "[#{xpath_for(query.model, query.conditions)}]" unless xpath
      end
      STDERR.puts "/#{container}#{xpath}"
      xpath = "/#{container}#{CGI.escape(xpath)}"
      records = Array.new
      puts "XPATH<#{xpath}>"
#      collection = get(CGI.escape(xpath)).root
#      collection.xpath("//#{container}", collection.namespace).each do |node|
#        records << node_to_record(query.model, node)
#      end
      records
    end

    ##
    # Convert feature (as xml) into record (as hash of key/value pairs)
    #
    # @param [Nokogiri::XML::Node] node
    #   A node
    #
    # @return [Hash]
    #   A hash of all of the properties for a particular record
    #
    # @api private
    def node_to_record(model, node)
      record = { }
      xpathmap = model.xpathmap rescue { }
      xmlnamespaces = model.xmlnamespaces rescue nil
#      STDERR.puts "MODEL node_to_record(#{model.properties}<#{node.class}>)"
      model.properties.each do |property|
        xpath = xpathmap[property.name] || property.name
#        STDERR.puts "PROPERTY node_to_record property(#{property.inspect})"
	key = property.name.to_s
	if key == "raw"
	  record[key] = node.to_s
	  next
	end
	children = node.xpath("./#{xpath}", xmlnamespaces)	
#	STDERR.puts "Property found: #{property.inspect} at #{xpath} with #{children.size} children"
	case children.size
	when 0
          next
	when 1
	  value = children.text.strip
#	  STDERR.puts "done: #{value.inspect}" if xpath =~ /done/
	  value = children.to_xml if value.empty?
	else
	  value = children.to_xml
	end
#	STDERR.puts "Key #{key}, Value #{value.inspect} <#{property.class}>"
	case property
	when DataMapper::Property::Date
	  require 'parsedate'
	  record[key] = Time.utc(ParseDate.parsedate(value))
	when DataMapper::Property::Integer
	  record[key] = value.to_s
	when DataMapper::Property::String
	  record[key] = value.to_s
	when DataMapper::Property::Boolean
	  record[key] = !value.nil?
	when DataMapper::Property::Class
#         STDERR.puts "Class property #{property.name.capitalize} value #{value.inspect}"
          case property.name
          when :productline
            val = DataMapper.const_get(property.name.capitalize).new
            val.id = children.attribute("id")
            val.name = value.to_s
          when :actors
            val = Array.new
            children.each do |node|
              actor = DataMapper.const_get("Actor").new
              actor.role = node.xpath("./role").text.to_s
              actor.userid = node.xpath("./person/userid").text.to_s
              actor.email = node.xpath("./person/email").text.to_s
              actor.fullname = node.xpath("./person/fullname").text.to_s
              val << actor
            end
          else
            raise TypeError, "'class' property #{property} not implemented"
          end
	  record[key] = val
	else
	  raise TypeError, "#{property} unsupported"
	end
      end
      record
    end
    def method_missing name, *args
      raise "KeeperAdapter: missing(#{name}, #{args.inspect})"
    end
  end # class
end # module
