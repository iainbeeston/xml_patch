require 'oga'
require 'xml_patch/errors/invalid_xml'
require 'xml_patch/errors/invalid_xpath'

module XmlPatch
  class TargetDocument
    def initialize(xml)
      @xml = Oga.parse_xml(xml)
    rescue LL::ParserError => e
      raise XmlPatch::Errors::InvalidXml, e.message
    end

    def to_xml
      xml.to_xml
    end

    def remove_at!(xpath)
      nodes = []

      begin
        nodes = xml.xpath(xpath)
      rescue LL::ParserError => e
        raise XmlPatch::Errors::InvalidXpath, e.message
      end

      nodes.each { |n| remove_node(n) }

      self
    end

    private

    attr_reader :xml

    def remove_node(node)
      if node.respond_to?(:remove)
        node.remove
      elsif node.respond_to?(:element)
        node.element.unset(node.name)
      end
    end
  end
end
