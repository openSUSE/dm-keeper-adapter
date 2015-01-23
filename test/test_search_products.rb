require File.join(File.dirname(__FILE__), 'helper')

class Search_product_test < Test::Unit::TestCase

  def setup
    DataMapper::Logger.new(STDOUT, :debug)
    @keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/product'
    require 'keeper/productline'
    DataMapper.finalize
  end
  
  def test_like_product
    features = Product.all(:shortname.like => 'SUSE Manager')
    assert features
    assert features.size > 0
#    puts "#{features.size} features have 'projects' in their title"
  end

end
