require File.join(File.dirname(__FILE__), 'helper')

class Search_productline_test < Test::Unit::TestCase

  def setup
    DataMapper::Logger.new(STDOUT, :debug)
    @keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/productline'
    DataMapper.finalize
  end
  
  def test_get_productline
    productline = Productline.get(22173)
    assert productline
#    puts "ID 22173: #{productline.inspect}"
  end

  def test_search_productline
    productline = Productline.all(:name => 'SUSE Manager')
    assert productline
    assert productline.size > 0
#    puts "#{productline.size} productlines have 'SUSE Manager' as their name"
  end

  def test_like_productline
    productlines = Productline.all(:name.like => 'SUSE Manager')
    assert productlines
    assert productlines.size > 0
#    puts "#{productlines.size} productlines have 'SUSE Manager' in their name"
  end

end
