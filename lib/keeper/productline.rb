require 'rubygems'
require 'dm-core'
class Productline
  include DataMapper::Resource
  def self.xpathmap
    { :id => "@k:id"
    }
  end
  def self.xmlnamespaces
    { "k" => "http://inttools.suse.de/sxkeeper/schema/keeper" }
  end
  property :id, Integer, :key => true
  property :name, String
end
