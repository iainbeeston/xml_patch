require 'spec_helper'
require 'xml_patch/operations/remove'
require 'xml_patch/xml_document'

RSpec.describe XmlPatch::Operations::Remove do
  describe 'sel' do
    it 'is the sel parameter passed to the constructor' do
      op = described_class.new(sel: 'foo/bar')
      expect(op.sel).to eq('foo/bar')
    end

    it 'cannot be mutated' do
      op = described_class.new(sel: 'foo/bar')
      expect {
        op.sel.gsub!(/.*/, '')
      }.to raise_error(RuntimeError).with_message("can't modify frozen String")
    end

    it 'is not the same object that was passed to the constructor' do
      str = 'foo/bar'
      op = described_class.new(sel: str)
      expect(op.sel).not_to be(str)
    end
  end

  describe 'apply_to' do
    it 'calls remove_at! on the document using sel' do
      op = described_class.new(sel: '/foo/bar')
      doc = XmlPatch::XmlDocument.new('')
      allow(doc).to receive(:remove_at!)
      op.apply_to(doc)
      expect(doc).to have_received(:remove_at!).with('/foo/bar')
    end

    it 'returns the input document' do
      op = described_class.new(sel: '/foo/bar')
      doc = XmlPatch::XmlDocument.new('')
      expect(op.apply_to(doc)).to eq(doc)
    end
  end

  describe 'operation' do
    it 'is remove' do
      expect(described_class.new(sel: '').operation).to eq(:remove)
    end
  end

  describe '==' do
    it 'is false if given a nil' do
      op = described_class.new(sel: '/foo/bar')
      expect(op).not_to eq(nil)
    end

    it 'is false if given an operation-like object with a different operation' do
      op = described_class.new(sel: '/foo/bar')
      expect(op).not_to eq(double('FakeOp', operation: :foo, sel: '/foo/bar'))
    end

    it 'is false if given a remove operation with a different sel' do
      op = described_class.new(sel: '/foo/bar')
      expect(op).not_to eq(described_class.new(sel: '/bar/foo'))
    end

    it 'is true if given a remove operation with the same sel' do
      op = described_class.new(sel: '/foo/bar')
      expect(op).to eq(described_class.new(sel: '/foo/bar'))
    end

    it 'is true if given itself' do
      op = described_class.new(sel: '/foo/bar')
      expect(op).to eq(op)
    end
  end

  describe 'to_xml' do
    it 'renders the operation as a <remove> tag' do
      op = described_class.new(sel: '/foo/bar')
      expect(op.to_xml).to eq('<remove sel="/foo/bar" />')
    end
  end
end
