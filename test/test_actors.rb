require File.join(File.dirname(__FILE__), 'helper')

class Actors_test < Test::Unit::TestCase

  def setup
    DataMapper::Logger.new(STDOUT, :debug)
    @keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/feature'
    DataMapper.finalize
  end
  
  def test_actors
    feature = Feature.get(312814)
    assert feature
    assert feature.actors
    assert feature.actors.size > 0
  end

end
