require 'rubygems'
require 'dm-core'
require 'keeper/milestone'
class Product
  include DataMapper::Resource
  def self.xpathmap
    { :id => "@k:id", :milestone => "milestone/name"
    }
  end
  def self.xmlnamespaces
    { "k" => "http://inttools.suse.de/sxkeeper/schema/keeper" }
  end
  property :id, Integer, :key => true
  has 1, :productline
  property :fatename, String
  property :shortname, String
  property :longname, String
  property :bugzillaname, String
  has n, :milestone
  # skip milestone, Array needs a custom type
  # skip component, Array needs a custom type
  property :releasedate, Date
end
