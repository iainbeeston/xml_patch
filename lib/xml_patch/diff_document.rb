module XmlPatch
  class DiffDocument
    include Enumerable

    def initialize
      @operations = []
    end

    def <<(operation)
      operations << operation
      self
    end

    def each(&blk)
      operations.each(&blk)
    end

    def apply_to(doc)
      operations.each { |op| op.apply_to(doc) }
      doc
    end

    def ==(other)
      other.respond_to?(:apply_to) &&
        other.respond_to?(:zip) &&
        other.zip(self).all? { |a, b| a == b }
    end

    def to_xml
      operations.inject('') { |str, op| str + op.to_xml + "\n" }.chomp
    end

    private

    attr_reader :operations
  end
end
