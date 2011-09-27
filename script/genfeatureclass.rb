    #
    # generate or update the class definition for 'Feature'
    #
    def update_featureclass path
      partsrevision = 0
      xmlfieldsrevision = 0
      if File.exists? path
	require path
	partsrevision = Feature.partsrevision
	xmlfieldsrevision = Feature.xmlfieldsrevision
      end
      current_partsrevision = revision_of('list_view_parts').to_i
      current_xmlfieldsrevision = revision_of('list_xmlfields').to_i
      if partsrevision < current_partsrevision || xmlfieldsrevision < current_xmlfieldsrevision
	# class needs regeneration
	File.open path, "w+" do |f|
	  f.puts("# File generated by dm-keeper-adapter on #{Time.new.asctime}")
	  f.puts("require 'rubygems'")
	  f.puts("require 'dm-core'")
	  f.puts("class Feature")
	  f.puts("  def Feature.partsrevision")
	  f.puts("    #{current_partsrevision}")
	  f.puts("  end")
	  f.puts("  def Feature.xmlfieldsrevision")
	  f.puts("    #{current_xmlfieldsrevision}")
	  f.puts("  end")
	  f.puts("  include DataMapper::Resource\n")
	  f.puts("  property :id, Integer, :key => true")
	  properties = []
	  viewparts.each_key do |k|
	    n = k.tr(" ","_").downcase
	    properties << n
	    f.puts("  property :#{n}, String")
	  end
	  xmlfields.each_key do |k|
	    n = k.tr(" ","_").downcase
	    next if n == '.'
	    next if properties.include? n
	    f.puts("  property :#{n}, String")
	  end
	  f.puts("end")	    
	end
      else
	puts "#{path} is up to date"
      end
    end

    def revision_of id
      node = valuelist.xpath("//valuelist[@id='#{id}']").first
      node.attribute_with_ns('revision', 'http://inttools.suse.de/sxkeeper/schema/keeper').value
    end
