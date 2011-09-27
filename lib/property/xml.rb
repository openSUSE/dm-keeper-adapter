require 'dm-core'
require 'nokogiri'

module DataMapper
  class Property
    class Xml < Object
      primitive String
      def dump(value)
	value.to_xml
      end
      def load(value)
	Nokogiri::XML value
      end
    end
    
    XML = Xml
  end
end
