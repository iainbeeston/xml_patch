require 'xml_patch/version'
require 'xml_patch/applicator'

module XmlPatch
  class << self
    def apply(xml)
      XmlPatch::Applicator.new(xml)
    end
  end
end
