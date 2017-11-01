require 'spec_helper'
require 'xml_patch/diff_document'
require 'xml_patch/target_document'

RSpec.describe XmlPatch::DiffDocument do
  it 'is enumerable' do
    expect(described_class.new).to be_an(Enumerable)
  end

  describe '<<' do
    it 'adds items onto the end of the document' do
      diff = described_class.new
      diff << 1
      diff << 2
      expect { |blk|
        diff.each(&blk)
      }.to yield_successive_args(1, 2)
    end

    it 'returns itself' do
      diff = described_class.new
      diff << 1
      expect(diff << 1).to be(diff)
    end
  end

  describe 'each' do
    it 'yields the operations in the order they were added' do
      diff = described_class.new
      diff << 1
      diff << 2
      expect { |blk|
        diff.each(&blk)
      }.to yield_successive_args(1, 2)
    end

    it 'returns an enumerator if no block is given' do
      diff = described_class.new
      expect(diff.each).to be_a(Enumerator)
    end
  end

  describe 'apply_to' do
    it 'applies each of the operations in order' do
      doc = XmlPatch::TargetDocument.new('')

      op1 = double('op1')
      allow(op1).to receive(:apply_to)
      op2 = double('op2')
      allow(op2).to receive(:apply_to)
      diff = described_class.new
      diff << op1
      diff << op2

      diff.apply_to(doc)

      expect(op1).to have_received(:apply_to).with(doc).ordered
      expect(op2).to have_received(:apply_to).with(doc).ordered
    end

    it 'returns the input document' do
      doc = XmlPatch::TargetDocument.new('')
      diff = described_class.new
      expect(diff.apply_to(doc)).to be(doc)
    end
  end

  describe '==' do
    it 'is false if given nil' do
      diff = described_class.new
      expect(diff).not_to eq(nil)
    end

    it 'is false if there are no operations and given an empty array' do
      diff = described_class.new
      expect(diff).not_to eq([])
    end

    it 'is false if given a diff with different operations' do
      diff_a = described_class.new << double('op1')
      diff_b = described_class.new << double('op2')

      expect(diff_a).not_to eq(diff_b)
    end

    it 'is true if given a diff with the same operations' do
      op = double('op')
      diff_a = described_class.new << op
      diff_b = described_class.new << op

      expect(diff_a).to eq(diff_b)
    end
  end

  describe 'to_xml' do
    it 'renders each of the operations to xml in order' do
      op1 = double('op1', to_xml: '<op1 />')
      op2 = double('op1', to_xml: '<op2 />')

      diff = described_class.new << op1 << op2

      expect(diff.to_xml).to eq("<op1 />\n<op2 />")
    end

    it 'is an empty string if there are no operations' do
      diff = described_class.new
      expect(diff.to_xml).to eq('')
    end
  end
end
