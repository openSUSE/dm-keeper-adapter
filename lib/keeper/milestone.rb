require 'rubygems'
require 'dm-core'
class Milestone
  include DataMapper::Resource
  property :name, String, :key => true
  property :sortorder, Integer
  property :display, Boolean
end
