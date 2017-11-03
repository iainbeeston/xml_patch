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

    def parse(patch)
      patch.parse do |name, attrs|
        case name
        when 'remove' then remove(attrs['sel'])
        end
      end
      self
    end
  end
end
