require 'spec_helper'
require 'xml_patch/operations/replace'
require 'xml_patch/xml_document'

RSpec.describe XmlPatch::Operations::Replace do
  describe 'sel' do
    it 'is the sel parameter passed to the constructor' do
      op = described_class.new(sel: 'foo/bar', document: XmlPatch::XmlDocument.new(''))
      expect(op.sel).to eq('foo/bar')
    end

    it 'cannot be mutated' do
      op = described_class.new(sel: 'foo/bar', document: XmlPatch::XmlDocument.new(''))
      expect {
        op.sel.gsub!(/.*/, '')
      }.to raise_error(RuntimeError).with_message("can't modify frozen String")
    end

    it 'is not the same object that was passed to the constructor' do
      str = 'foo/bar'
      op = described_class.new(sel: str, document: XmlPatch::XmlDocument.new(''))
      expect(op.sel).not_to be(str)
    end
  end

  describe 'document' do
    it 'is the document parameter passed to the constructor' do
      doc = XmlPatch::XmlDocument.new('<baz />')
      op = described_class.new(sel: '', document: doc)
      expect(op.document).to eq(doc)
    end

    it 'cannot be mutated' do
      doc = XmlPatch::XmlDocument.new('<baz />')
      op = described_class.new(sel: '', document: doc)
      expect {
        op.document.remove('//baz')
      }.to raise_error(RuntimeError).with_message("can't modify frozen XmlDocument")
    end

    it 'is not the same object that was passed to the constructor' do
      doc = XmlPatch::XmlDocument.new('<baz />')
      op = described_class.new(sel: '', document: doc)
      expect(op.document).not_to be(doc)
    end
  end

  describe 'apply_to' do
    it 'calls replace_at! on the document using sel and document' do
      doc = XmlPatch::XmlDocument.new('<baz />')
      op = described_class.new(sel: '/foo/bar', document: doc)
      target = instance_double(XmlPatch::XmlDocument)
      allow(target).to receive(:replace_at!)
      op.apply_to(target)
      expect(target).to have_received(:replace_at!).with('/foo/bar', doc)
    end

    it 'returns the input document' do
      doc = XmlPatch::XmlDocument.new('<baz />')
      op = described_class.new(sel: '/foo/bar', document: doc)
      target = instance_double(XmlPatch::XmlDocument)
      allow(target).to receive(:replace_at!)
      expect(op.apply_to(target)).to be(target)
    end
  end

  describe 'operation' do
    it 'is replace' do
      expect(described_class.new(sel: '', document: XmlPatch::XmlDocument.new('')).operation).to eq(:replace)
    end
  end

  describe '==' do
    it 'is false if given a nil' do
      op = described_class.new(sel: '/foo/bar', document: '<baz />')
      expect(op).not_to eq(nil)
    end

    it 'is false if given an operation-like object with a different operation' do
      op = described_class.new(sel: '/foo/bar', document: '<baz />')
      expect(op).not_to eq(double('FakeOp', operation: :foo, sel: '/foo/bar', document: '<baz />'))
    end

    it 'is false if given a replace operation with a different sel' do
      op = described_class.new(sel: '/foo/bar', document: '<baz />')
      expect(op).not_to eq(described_class.new(sel: '/bar/foo', document: '<baz />'))
    end

    it 'is false if given a replace operation with different document' do
      op = described_class.new(sel: '/foo/bar', document: XmlPatch::XmlDocument.new('<baz />'))
      expect(op).not_to eq(described_class.new(sel: '/foo/bar', document: XmlPatch::XmlDocument.new('<qux />')))
    end

    it 'is true if given a replace operation with the same sel and document' do
      op = described_class.new(sel: '/foo/bar', document: XmlPatch::XmlDocument.new('<baz />'))
      expect(op).to eq(described_class.new(sel: '/foo/bar', document: XmlPatch::XmlDocument.new('<baz />')))
    end

    it 'is true if given itself' do
      op = described_class.new(sel: '/foo/bar', document: XmlPatch::XmlDocument.new('<baz />'))
      expect(op).to eq(op)
    end
  end

  describe 'to_xml' do
    it 'renders the operation as a <replace> tag' do
      op = described_class.new(sel: '/foo/bar', document: XmlPatch::XmlDocument.new('<baz />'))
      expect(op.to_xml).to eq('<replace sel="/foo/bar"><baz /></replace>')
    end
  end
end
