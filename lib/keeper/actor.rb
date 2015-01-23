require 'rubygems'
require 'dm-core'
require 'keeper/person'
class Actor
  include DataMapper::Resource
  property :role, String, :key => true
  has 1, :person
end
