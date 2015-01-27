require File.join(File.dirname(__FILE__), 'helper')

class Query_test < Test::Unit::TestCase

  def setup
    DataMapper::Logger.new(STDOUT, :debug)
    @keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/productline'
    require 'keeper/product'
    require 'keeper/feature'
    DataMapper.finalize
  end

  # test get key
  def xtest_get_feature
    feature = Feature.get(312814)
#    assert feature
#    assert_equal 312814,feature.id
  end

  # test all
  def xtest_all_productlines
    productlines = Productline.all()
#    assert productlines
#    assert productlines.size > 0
  end
  
  # test all by key
  def xtest_get_product_by_id
    product = Product.all(:id => 22241)
    assert product
    assert_equal 22241, product.id
  end
  
  # test filter by attr property
  def xtest_product_by_productline
    products = Product.all(:productline_id => 22173)
    assert products
    assert products.size > 0
  end
  
  # filter by text property
  def test_product_by_name
    products = Productline.all(:name => "SUSE Manager")
    assert products
    assert products.size > 0
  end
end
