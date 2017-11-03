require 'xml_patch/diff_builder'
require 'xml_patch/xml_document'

module XmlPatch
  class Applicator
    def initialize(patch)
      @patch = patch
    end

    def to(target_xml)
      target = XmlPatch::XmlDocument.new(target_xml)
      diff_document.apply_to(target)
      target.to_xml
    end

    private

    attr_reader :patch

    def diff_document
      XmlPatch::DiffBuilder.new.parse(patch).diff_document
    end
  end
end
