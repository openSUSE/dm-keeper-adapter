require 'rubygems'
require 'dm-core'
class Relation
  include DataMapper::Resource
  def self.xpathmap
    { :target => "@target", :sort_position => "@sortPosition" }
  end
  property :target, Integer, :key => true
  property :sort_position, Integer
  has 1, :parent, self
  belongs_to :relation, :required => false
  belongs_to :relationtree, :required => false
end
