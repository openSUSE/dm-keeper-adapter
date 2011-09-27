require 'rubygems'
require 'dm-core'
class Product
  include DataMapper::Resource
  property :id, Integer, :key => true
  has 1, :productline
  property :fatename, String
  property :shortname, String
  property :longname, String
  property :bugzillaname, String
  has n, :milestone
  has n, :component
  property :releasedate, Date
end
