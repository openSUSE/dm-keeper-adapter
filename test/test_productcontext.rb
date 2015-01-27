require File.join(File.dirname(__FILE__), 'helper')

class Productcontext_test < Test::Unit::TestCase

  def setup
    DataMapper::Logger.new(STDOUT, :debug)
    @keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/productline'
    require 'keeper/productcontext'
    require 'keeper/product'
    require 'keeper/feature'
    DataMapper.finalize
  end

  # test get key
  def test_get_feature
    feature = Feature.get(313024)
    assert feature
    assert feature.productcontexts
    assert_equal 4, feature.productcontexts.size
#    feature.productcontexts.each do |product|
#      puts product
#    end
  end
end
