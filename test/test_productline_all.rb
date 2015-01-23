require File.join(File.dirname(__FILE__), 'helper')

class Productline_all_test < Test::Unit::TestCase

  def setup
    DataMapper::Logger.new(STDOUT, :debug)
    @keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/productline'
    DataMapper.finalize
  end
  
  def test_productline_all
    productlines = Productline.all
    assert productlines
    assert productlines.size > 0
  end

end
