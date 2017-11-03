require 'oga'
require 'xml_patch/errors/invalid_xml'
require 'xml_patch/errors/invalid_xpath'

module XmlPatch
  class XmlDocument
    def initialize(xml)
      @xml = xml
    end

    def to_xml
      xml_dom.to_xml
    end

    def remove_at!(xpath)
      nodes = []

      begin
        nodes = xml_dom.xpath(xpath)
      rescue LL::ParserError => e
        raise XmlPatch::Errors::InvalidXpath, e.message
      end

      nodes.each { |n| remove_node(n) }

      self
    end

    def parse(&blk)
      handler = SaxHandler.new(&blk)
      Oga.sax_parse_xml(handler, xml)
      nil
    end

    private

    attr_reader :xml

    def xml_dom
      @xml_dom ||= Oga.parse_xml(xml)
    rescue LL::ParserError => e
      raise XmlPatch::Errors::InvalidXml, e.message
    end

    def remove_node(node)
      if node.respond_to?(:remove)
        node.remove
      elsif node.respond_to?(:element)
        node.element.unset(node.name)
      end
    end

    class SaxHandler
      attr_reader :block

      def initialize(&block)
        @block = block
      end

      def on_element(_namespace, name, attrs = {})
        block.call(name, attrs)
      end
    end

    private_constant :SaxHandler
  end
end
