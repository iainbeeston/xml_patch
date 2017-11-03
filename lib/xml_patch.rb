require 'xml_patch/version'
require 'xml_patch/applicator'
require 'xml_patch/xml_document'

module XmlPatch
  class << self
    def apply(xml)
      patch = XmlPatch::XmlDocument.new(xml)
      XmlPatch::Applicator.new(patch)
    end
  end
end
