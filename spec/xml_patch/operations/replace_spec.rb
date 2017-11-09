require 'spec_helper'
require 'xml_patch/operations/replace'
require 'xml_patch/xml_document'

RSpec.describe XmlPatch::Operations::Replace do
  describe 'sel' do
    it 'is the sel parameter passed to the constructor' do
      op = described_class.new(sel: 'foo/bar', content: '')
      expect(op.sel).to eq('foo/bar')
    end

    it 'cannot be mutated' do
      op = described_class.new(sel: 'foo/bar', content: '')
      expect {
        op.sel.gsub!(/.*/, '')
      }.to raise_error(RuntimeError).with_message("can't modify frozen String")
    end

    it 'is not the same object that was passed to the constructor' do
      str = 'foo/bar'
      op = described_class.new(sel: str, content: '')
      expect(op.sel).not_to be(str)
    end
  end

  describe 'content' do
    it 'is the content parameter passed to the constructor' do
      op = described_class.new(sel: '', content: '<baz />')
      expect(op.content).to eq('<baz />')
    end

    it 'cannot be mutated' do
      op = described_class.new(sel: '', content: '<baz />')
      expect {
        op.content.gsub!(/.*/, '')
      }.to raise_error(RuntimeError).with_message("can't modify frozen String")
    end

    it 'is not the same object that was passed to the constructor' do
      content = '<baz />'
      op = described_class.new(sel: '', content: content)
      expect(op.content).not_to be(content)
    end
  end

  describe 'apply_to' do
    it 'calls replace_at! on the document using sel and content' do
      op = described_class.new(sel: '/foo/bar', content: '<baz />')
      doc = instance_double(XmlPatch::XmlDocument)
      allow(doc).to receive(:replace_at!)
      op.apply_to(doc)
      expect(doc).to have_received(:replace_at!).with('/foo/bar', '<baz />')
    end

    it 'returns the input document' do
      op = described_class.new(sel: '/foo/bar', content: '<baz />')
      doc = instance_double(XmlPatch::XmlDocument)
      allow(doc).to receive(:replace_at!)
      expect(op.apply_to(doc)).to eq(doc)
    end
  end

  describe 'operation' do
    it 'is replace' do
      expect(described_class.new(sel: '', content: '').operation).to eq(:replace)
    end
  end

  describe '==' do
    it 'is false if given a nil' do
      op = described_class.new(sel: '/foo/bar', content: '<baz />')
      expect(op).not_to eq(nil)
    end

    it 'is false if given an operation-like object with a different operation' do
      op = described_class.new(sel: '/foo/bar', content: '<baz />')
      expect(op).not_to eq(double('FakeOp', operation: :foo, sel: '/foo/bar', content: '<baz />'))
    end

    it 'is false if given a replace operation with a different sel' do
      op = described_class.new(sel: '/foo/bar', content: '<baz />')
      expect(op).not_to eq(described_class.new(sel: '/bar/foo', content: '<baz />'))
    end

    it 'is false if given a replace operation with different content' do
      op = described_class.new(sel: '/foo/bar', content: '<baz />')
      expect(op).not_to eq(described_class.new(sel: '/foo/bar', content: '<qux />'))
    end

    it 'is true if given a replace operation with the same sel and content' do
      op = described_class.new(sel: '/foo/bar', content: '<baz />')
      expect(op).to eq(described_class.new(sel: '/foo/bar', content: '<baz />'))
    end

    it 'is true if given itself' do
      op = described_class.new(sel: '/foo/bar', content: '<baz />')
      expect(op).to eq(op)
    end
  end

  describe 'to_xml' do
    it 'renders the operation as a <replace> tag' do
      op = described_class.new(sel: '/foo/bar', content: '<baz />')
      expect(op.to_xml).to eq('<replace sel="/foo/bar"><baz /></replace>')
    end
  end
end
