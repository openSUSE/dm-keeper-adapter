require 'rubygems'
require 'dm-core'
class Productcontext
  include DataMapper::Resource
  def self.xpathmap
    { :id => "product/productid",
      :name => "product/name"
    }
  end
  def self.xmlnamespaces
    { "k" => "http://inttools.suse.de/sxkeeper/schema/keeper" }
  end
  property :id, Integer, :key => true
  property :name, String
  property :rejected, Boolean
  property :done, Boolean
  property :duplicate, Boolean
  def to_s
    "#{self.id}: #{self.name} done #{self.done}, rejected #{self.rejected}, dup #{self.duplicate}"
  end
end
