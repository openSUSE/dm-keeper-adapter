require 'rubygems'
require 'dm-core'
require 'dm-types'

require 'keeper/relation'

class Relationtree
  include DataMapper::Resource
  def self.xpathmap
    { :id => "@k:id" }
  end
  def self.xmlnamespaces
    { "k" => "http://inttools.suse.de/sxkeeper/schema/keeper" }
  end
  property :id, Integer, :key => true
  property :title, String
  property :description, String
  property :raw, String
# fixme:  has n, :relations
  
  #
  # Workaround for missing association (see relation.rb)
  # Save relationtree xml in 'raw' and parse it when 'Relationtree#relations' is accessed
  # (should be a DataMapper::Associations::OneToMany::Collection :-/ )
  #
  
  def node2relation node, parent = nil
    rel = Relation.new( :target => node["target"] , :sort_position => node["sortPosition"], :parent => (parent) ? parent.target : nil)
    node.element_children.each do |child|
      relchild = node2relation(child, rel)
    end
    rel
  end
  
  # convert 'raw' into Relations
  def relations
    retval = []
    require 'nokogiri'
    xml = Nokogiri::XML.parse @raw
    parent = nil
    xml.root.xpath("/relationtree/relation").each do |rel|
      retval << node2relation(rel)
    end
    retval
  end
end
