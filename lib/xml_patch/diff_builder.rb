require 'oga'
require 'xml_patch/diff_document'
require 'xml_patch/operations/remove'

module XmlPatch
  class DiffBuilder
    attr_reader :diff_document

    def initialize
      @diff_document = XmlPatch::DiffDocument.new
    end

    def remove(xpath)
      diff_document << XmlPatch::Operations::Remove.new(sel: xpath)
    end

    def parse(xml)
      handler = SaxHandler.new(self)
      Oga.sax_parse_xml(handler, xml)
      self
    end

    class SaxHandler
      attr_reader :builder

      def initialize(builder)
        @builder = builder
      end

      def on_element(_namespace, name, attrs = {})
        case name
        when 'remove' then builder.remove(attrs['sel'])
        end
      end
    end

    private_constant :SaxHandler
  end
end
