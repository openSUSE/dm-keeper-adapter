require 'rubygems'
require 'dm-core'
class Relation
  include DataMapper::Resource
  def self.xpathmap
    { :target => "@target", :sort_position => "@sortPosition" }
  end
  property :target, Integer, :key => true
  property :sort_position, Integer
  # workaround for non-working associations
  property :parent, Integer
  
  # this is how it should be - how to implement it in the adapter ??
#  has 1, :parent, self
#  belongs_to :relation, :required => false
#  has n, :children, self
#  belongs_to :relationtree, :required => false
end
