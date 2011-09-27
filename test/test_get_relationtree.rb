require File.join(File.dirname(__FILE__), 'helper')

class Get_relationtree_test < Test::Unit::TestCase

  def setup
    DataMapper::Logger.new(STDOUT, :debug)
    @keeper = DataMapper.setup(:default,
			      :adapter => 'keeper',
			      :url  => 'https://keeper.novell.com/sxkeeper')

    require 'keeper/relationtree'
    DataMapper.finalize
  end

  def test_get_relationtree_by_id
    # Access relationtree by id
    tree = Relationtree.get(1137)
    assert tree
  end

  def test_get_relationtree_by_name
    # Access relationtree by name
    tree = Relationtree.first(:title => "Manager 1.2.1")
    assert tree
    assert_equal 1137, tree.id
  end
end
