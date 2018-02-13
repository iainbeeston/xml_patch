require 'xml_patch/diff_document'
require 'xml_patch/operations/remove'
require 'xml_patch/operations/replace'

module XmlPatch
  class DiffBuilder
    attr_reader :diff_document

    def initialize
      @diff_document = XmlPatch::DiffDocument.new
    end

    def remove(xpath)
      diff_document << XmlPatch::Operations::Remove.new(sel: xpath)
    end

    def replace(xpath, content)
      diff_document << XmlPatch::Operations::Replace.new(sel: xpath, document: content)
    end

    def parse(patch)
      patch.get_at('/diff/*') do |name, attrs, content|
        case name
        when 'remove' then remove(attrs['sel'])
        when 'replace' then replace(attrs['sel'], content)
        end
      end
      self
    end
  end
end
