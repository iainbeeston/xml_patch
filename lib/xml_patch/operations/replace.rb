module XmlPatch
  module Operations
    class Replace
      attr_reader :sel, :document

      def initialize(sel:, document:)
        @sel = sel.dup.freeze
        @document = document.dup.freeze
      end

      def apply_to(doc)
        doc.replace_at!(sel, document)
        doc
      end

      def ==(other)
        other.respond_to?(:operation) &&
          other.operation == operation &&
          other.respond_to?(:sel) &&
          other.sel == sel &&
          other.respond_to?(:document) &&
          other.document == document
      end

      def operation
        :replace
      end

      def to_xml
        %(<replace sel="#{sel}">#{document.to_xml}</replace>)
      end
    end
  end
end
