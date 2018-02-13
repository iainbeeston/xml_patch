require 'oga'
require 'xml_patch/errors/invalid_xml'
require 'xml_patch/errors/invalid_xpath'

module XmlPatch
  class XmlDocument
    def initialize(xml)
      @xml_dom = xml.respond_to?(:to_xml) ? xml : parse_xml(xml.to_str)
    end

    def to_xml
      xml_dom.to_xml
    end

    def remove_at!(xpath)
      raise(RuntimeError, "can't modify frozen #{self.class.name}") if frozen?

      nodes_at(xpath).each { |n| remove_node(n) }

      self
    end

    def replace_at!(xpath, content)
      raise(RuntimeError, "can't modify frozen #{self.class.name}") if frozen?

      nodes_at(xpath).each { |n| replace_node(n, content) }

      self
    end

    def get_at(xpath)
      if block_given?
        nodes_at(xpath).each do |n|
          yield(n.name, node_attributes(n), n.children.any? ? document_from_nodes(n.children) : nil)
        end
      end

      self
    end

    private

    attr_reader :xml_dom

    def parse_xml(xml)
      Oga.parse_xml(xml)
    rescue LL::ParserError => e
      raise XmlPatch::Errors::InvalidXml, e.message
    end

    def document_from_nodes(nodes)
      oga_document = Oga::XML::Document.new(
        doctype: xml_dom.doctype,
        xml_declaration: xml_dom.xml_declaration,
        children: nodes.to_a
      )
      self.class.new(oga_document)
    end

    def remove_node(node)
      if node.respond_to?(:remove)
        node.remove
      elsif node.respond_to?(:element)
        node.element.unset(node.name)
      end
    end

    def replace_node(node, content)
      if node.respond_to?(:replace)
        new_node = parse_xml(content).children.first
        if new_node
          node.replace(new_node)
        else
          node.remove
        end
      elsif node.respond_to?(:element)
        node.value = content
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
