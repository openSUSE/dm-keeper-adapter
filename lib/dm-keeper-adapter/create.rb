# create.rb
module DataMapper::Adapters
class KeeperAdapter < AbstractAdapter
  def create(resources)
    table_groups = group_resources_by_table(resources)
    table_groups.each do |table, resources|
      # make
      #  class User
      #    property :id, Serial
      #  end
      # work
      resources.each do |resource|
	initialize_serial(resource,
			  worksheet_record_cound(table)+1)
	post_resource_to_worksheet(resource,table)
      end
    end
    resources.size
  end
end
end
