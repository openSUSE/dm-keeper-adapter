# read.rb
module DataMapper::Adapters
  class KeeperAdapter < AbstractAdapter
    require 'nokogiri'
    def read(query)
      records = records_for(query)
#      query.filter_records(records)
    end

  private
    # taken from https://github.com/whoahbot/dm-redis-adapter/
    
    ##
    # Retrieves records for a particular model.
    #
    # @param [DataMapper::Query] query
    #   The query used to locate the resources
    #
    # @return [Array]
    #   An array of hashes of all of the records for a particular model
    #
    # @api private
    def records_for(query)
#      $stderr.puts "records_for(#{query})"
#      $stderr.puts "records_for(#{query.inspect})"
      records = []
      if query.conditions.nil?
	# return all
      else
	query.conditions.operands.each do |operand|
	  if operand.is_a?(DataMapper::Query::Conditions::OrOperation)
	    operand.each do |op|
	      records = records + perform_query(query, op)
	    end
	  else
	    records = perform_query(query, operand)
	  end
	end
      end      
      records
    end #def

    ##
    # Find records that match have a matching value
    #
    # @param [DataMapper::Query] query
    #   The query used to locate the resources
    #
    # @param [DataMapper::Operation] the operation for the query
    #
    # @return [Array]
    #   An array of hashes of all of the records for a particular model
    #
    # @api private
    def perform_query(query, operand)
#      $stderr.puts "perform_query(#{query},#{operand})"
      records = []
		    
      if operand.is_a?(DataMapper::Query::Conditions::NotOperation)
	subject = operand.first.subject
	value = operand.first.value
      elsif operand.subject.is_a?(DataMapper::Associations::ManyToOne::Relationship)
	subject = operand.subject.child_key.first
	value = operand.value[operand.subject.parent_key.first.name]
      else
	subject = operand.subject
	value =  operand.value
      end
      
      if subject.is_a?(DataMapper::Associations::ManyToOne::Relationship)
	subject = subject.child_key.first
      end
      
      # typical queries
      #
      # ?query=/feature[
      #   productcontext[
      #    not (status[done or rejected or duplicate or unconfirmed])
      #  ]
      #  and
      #  actor[
      #    (person/userid='kkaempf@novell.com' or person/email='kkaempf@novell.com' or person/fullname='kkaempf@novell.com')
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
      
#      $stderr.puts "perform_query(subject #{subject.inspect},#{value.inspect})"
      container = query.model.to_s.downcase
      if query.model.key.include?(subject)
	# get single <feature>
	records << node_to_record(query.model, get("/#{container}/#{value}").root)
      else
	# query, get <collection>[<object><feature>...]*
	xpath = "/#{container}["
	# ...
	xpath << "]"
	collection = get("/#{container}?query=#{xpath}")
	collection.xpath("/#{container}").each do |feature|
	  records << node_to_record(query.model, feature)
	end
      end
      
      records
    end # def

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
#      $stderr.puts "node_to_record(#{model}:#{node.class})"
      model.properties.each do |property|
	xpath = xpathmap[property.name] || property.name
	key = property.name.to_s
	children = node.xpath("./#{xpath}", xmlnamespaces)	
#	$stderr.puts "Property found: #{property.inspect}"
	case children.size
	when 0: next
	when 1: value = children.text
	else
	  value = children.to_xml
	end
#	$stderr.puts "Key #{key}, Value #{value} <#{property.class}>"
	case property
	when DataMapper::Property::Date
	  require 'parsedate'
	  record[key] = Time.utc(ParseDate.parsedate(value))
	when DataMapper::Property::Integer
	  record[key] = value.to_s
	when DataMapper::Property::String
	  record[key] = value.to_s
	else
	  raise TypeError, "#{property} unsupported"
	end
      end
      model.relationships.each do |rel|
#	$stderr.puts "Rel ? #{rel.inspect}"
	children = node.xpath("./#{rel.child_model_name.downcase}")
	value = []
	while n = children.shift
	  value << node_to_record(rel.child_model, n)
	end
	record[rel.name.to_s] = value
#	$stderr.puts "#{rel.name} -> #{value.inspect}"
      end
      record
    end
  end # class
end # module
