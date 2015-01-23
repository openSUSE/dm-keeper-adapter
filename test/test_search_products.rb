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
    products = Product.all(:shortname.like => 'SUSE Manager')
    assert products
    assert products.size > 0
    products.each do |prod|
      assert_equal 22173, prod.productline.id
    end
  end

  def test_has_productline
    suma = Productline.all(:name => "SUSE Manager").first
    puts "suma #{suma}"
    products = Product.all(:productline => suma.id)
    assert products
    assert products.size > 0
  end

  def test_get_product
    product = Product.get(22241)
    assert product
    puts "Productline #{product.productline.inspect}"
  end

end
