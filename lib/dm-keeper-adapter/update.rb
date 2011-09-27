# update.rb
module DataMapper::Adapters
class KeeperAdapter < AbstractAdapter
  def update(attributes, collection)
    each_resource_with_edit_url(collection) do |resource, edit_url|
      put_updated_resource(edit_url, resource)
    end
    # return count
    collection.size
  end
end
end
