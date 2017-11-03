require 'xml_patch/diff_builder'
require 'xml_patch/xml_document'

module XmlPatch
  class Applicator
    attr_reader :diff_xml

    def initialize(diff_xml)
      @diff_xml = diff_xml.dup.freeze
    end

    def to(target_xml)
      diff = XmlPatch::DiffBuilder.new.parse(diff_xml).diff_document
      target = XmlPatch::XmlDocument.new(target_xml)
      diff.apply_to(target)
      target.to_xml
    end
  end
end
