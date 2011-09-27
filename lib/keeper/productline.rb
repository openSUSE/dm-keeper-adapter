require 'rubygems'
require 'dm-core'
class Productline
  include DataMapper::Resource
  property :id, Integer, :key => true
  property :name, String
end
