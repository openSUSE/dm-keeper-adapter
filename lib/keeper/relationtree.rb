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
#  has n, :relations
  property :relations, Csv
end
