module XmlPatch
  module Operations
    class Replace
      attr_reader :sel, :content

      def initialize(sel:, content:)
        @sel = sel.dup.freeze
        @content = content.dup.freeze
      end

      def apply_to(doc)
        doc.replace_at!(sel, content)
        doc
      end

      def ==(other)
        other.respond_to?(:operation) &&
          other.operation == operation &&
          other.respond_to?(:sel) &&
          other.sel == sel &&
          other.respond_to?(:content) &&
          other.content == content
      end

      def operation
        :replace
      end

      def to_xml
        %(<replace sel="#{sel}">#{content}</replace>)
      end
    end
  end
end
