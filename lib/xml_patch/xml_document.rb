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
      nodes_at(xpath).each { |n| remove_node(n) }

      self
    end

    def get_at(xpath)
      if block_given?
        nodes_at(xpath).each { |n| yield(n.name, node_attributes(n)) }
      end

      self
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

    def nodes_at(xpath)
      return xml_dom.xpath(xpath)
    rescue LL::ParserError => e
      raise XmlPatch::Errors::InvalidXpath, e.message
    end

    def node_attributes(node)
      node.attributes.each_with_object({}) do |attr, hsh|
        hsh[attr.name] = attr.value
      end
    end
  end
end
