require 'rubygems'
require 'dm-core'
class Person
  include DataMapper::Resource
  property :userid, String, :key => true
  property :email, String
  property :fullname, String
end
