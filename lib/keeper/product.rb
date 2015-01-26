require 'rubygems'
require 'dm-core'
require 'keeper/productline'
require 'keeper/component'
require 'keeper/milestone'
class Product
  include DataMapper::Resource
  def self.xpathmap
    { :id => "@k:id",
      :milestone => "milestone/name",
      :productline_id => "productline/@id"
    }
  end
  def self.xmlnamespaces
    { "k" => "http://inttools.suse.de/sxkeeper/schema/keeper" }
  end
  property :id, Integer, :key => true
  property :productline_id, Integer
  property :fatename, String
  property :shortname, String
  property :longname, String
  property :bugzillaname, String
#  has n, :milestones
#  has n, :components
  property :releasedate, Date
  def to_s
    "#{self.id}: #{self.shortname} (#{self.productline_id})"
  end
end
