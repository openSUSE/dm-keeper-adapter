# delete.rb
module DataMapper::Adapters
class KeeperAdapter < AbstractAdapter
  def delete(collection)
    each_resource_with_edit_url(collection) do |resource, edit_url|
      connection.delete(edit_url, 'If-Match' => "*")
    end
    # return count
    collection.size
  end
end
end
