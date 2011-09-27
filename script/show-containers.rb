#
# show-containers.rb
#
# Demo script to extract available 'containers' (aka database tables)
# from FATE (keeper.suse.de) using DataMapper
#

$: << File.join(File.dirname(__FILE__), "..", "dm-keeper-adapter", "lib")

require 'rubygems'
require 'dm-core'
require 'keeper/container'

DataMapper::Logger.new($stdout, :debug)
keeper = DataMapper.setup(:default, :adapter   => 'keeper',
			    :url  => 'https://keeper.novell.com/sxkeeper')

c = Keeper::Container.new keeper
c.each do |e|
  puts e
end
	