require 'rubygems'
require 'dm-core'
class Component
  include DataMapper::Resource
  property :name, String, :key => true
  property :description, String
end
