require 'rubygems'
require 'dm-core'
class Actor
  include DataMapper::Resource
  property :role, String, :key => true
  property :userid, String, :key => true
  property :email, String
  property :fullname, String
  def to_s
    "#{self.role}: #{self.userid}<#{self.email}>(#{self.fullname})"
  end
end
