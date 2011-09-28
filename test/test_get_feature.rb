require File.join(File.dirname(__FILE__), 'helper')

class Get_feature_test < Test::Unit::TestCase

  def test_get_feature
    DataMapper::Logger.new(STDOUT, :debug)
    keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/feature'
    DataMapper.finalize

    feature = Feature.get(312814)
    assert feature
    assert_equal 312814, feature.id
    puts "Feature #{feature.inspect}"
  end

end
