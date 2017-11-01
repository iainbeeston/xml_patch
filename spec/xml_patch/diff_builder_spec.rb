require 'spec_helper'
require 'xml_patch/diff_builder'
require 'xml_patch/diff_document'
require 'xml_patch/operations/remove'

RSpec.describe XmlPatch::DiffBuilder do
  describe 'remove' do
    it 'appends a remove operation to the diff document' do
      builder = described_class.new
      builder.remove('/foo/bar')
      builder.remove('/baz/qux')

      doc = XmlPatch::DiffDocument.new \
            << XmlPatch::Operations::Remove.new(sel: '/foo/bar') \
            << XmlPatch::Operations::Remove.new(sel: '/baz/qux')
      expect(builder.diff_document).to eq(doc)
    end
  end

  describe 'parse' do
    it 'does nothing when given an empty string' do
      diff = XmlPatch::DiffDocument.new

      builder = described_class.new
      builder.parse('')

      expect(builder.diff_document).to eq(diff)
    end

    it 'ignores any unrecognised xml tags' do
      diff = XmlPatch::DiffDocument.new

      builder = described_class.new
      builder.parse('<foo />')

      expect(builder.diff_document).to eq(diff)
    end

    it 'calls remove for each <remove> in the input' do
      xml = <<-XML
        <remove sel="/foo/bar" />
        <remove sel="/baz/qux" />
      XML

      builder = described_class.new
      allow(builder).to receive(:remove)

      builder.parse(xml)

      expect(builder).to have_received(:remove).with('/foo/bar').ordered
      expect(builder).to have_received(:remove).with('/baz/qux').ordered
    end
  end
end
