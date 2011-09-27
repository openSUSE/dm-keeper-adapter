#
# Feature for datamapper
#
require 'rubygems'
require 'dm-core'

class Feature
  include DataMapper::Resource

  def self.xpathmap
    { :id => "@k:id", :milestone => "productcontext/milestone/name", :actors => "actor",
      :requester => "actor[role='requester']/person/email",
      :productmgr => "actor[role='productmanager']/person/email",
      :projectmgr => "actor[role='projectmanager']/person/email",
      :engmgr => "actor[role='teamleader']/person/email",
      :developer => "actor[role='developer']/person/email"
    }
  end
  def self.xmlnamespaces
    { "k" => "http://inttools.suse.de/sxkeeper/schema/keeper" }
  end
  
  property :id, Integer, :key => true
  property :title, String
  property :requester, String
  property :productmgr, String
  property :projectmgr, String
  property :engmgr, String
  property :developer, String
  property :milestone, String
end
