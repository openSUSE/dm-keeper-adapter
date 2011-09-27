#!/bin/env ruby
#
# Generate/update class definition for 'Feature'

require 'lib/dm-keeper-adapter'

adapter = DataMapper.setup(:default, :adapter   => 'keeper',
			    :url  => 'https://keeper.novell.com/sxkeeper')

adapter.update_featureclass "feature.rb"
