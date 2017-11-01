module XmlPatch
  module Operations
    class Remove
      attr_reader :sel

      def initialize(sel:)
        @sel = sel.dup.freeze
      end

      def apply_to(doc)
        doc.remove_at!(sel)
      end

      def ==(other)
        other.respond_to?(:operation) &&
          other.operation == operation &&
          other.respond_to?(:sel) &&
          other.sel == sel
      end

      def operation
        :remove
      end

      def to_xml
        %(<remove sel="#{sel}" />)
      end
    end
  end
end
