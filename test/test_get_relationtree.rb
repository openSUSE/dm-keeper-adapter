require File.join(File.dirname(__FILE__), 'helper')

class Get_relationtree_test < Test::Unit::TestCase

  def test_get_relationtree
    DataMapper::Logger.new(STDOUT, :debug)
    keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/relationtree'
    DataMapper.finalize

    tree = Relationtree.get(1137)
    assert tree
    puts "Relationtree #{tree.inspect}"
  end

end
