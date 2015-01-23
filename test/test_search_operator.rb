require File.join(File.dirname(__FILE__), 'helper')

class Search_feature_test < Test::Unit::TestCase

  def setup
    DataMapper::Logger.new(STDOUT, :debug)
    @keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/feature'
    DataMapper.finalize
  end
  
  def test_like_feature
    features = Feature.all(:title.like => 'projects')
    assert features
    assert features.size > 0
#    puts "#{features.size} features have 'projects' in their title"
  end

  def test_equal_feature
    features = Feature.all(:title => 'Projects, planning, and priorities')
    assert features
    assert_equal 1, features.size
    f = features[0]
    assert_equal 312814, f.id
  end

  def test_hackweek7
    f1 = Feature.all(:product => 'Hackweek VII')
    f2 = Feature.all(:productid => 'hackweek_7')
    assert_equal f1.size, f2.size
#    puts "#{f1.size} projects registered for Hackweek 7"
  end

end
