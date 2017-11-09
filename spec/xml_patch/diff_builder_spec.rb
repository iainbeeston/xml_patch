require 'spec_helper'
require 'xml_patch/diff_builder'
require 'xml_patch/diff_document'
require 'xml_patch/xml_document'
require 'xml_patch/operations/remove'

RSpec.describe XmlPatch::DiffBuilder do
  describe 'remove' do
    it 'appends a remove operation to the diff document' do
      builder = described_class.new
      doc = builder.diff_document
      allow(doc).to receive(:<<)

      builder.remove('/foo/bar')
      builder.remove('/baz/qux')

      expect(doc).to have_received(:<<).with(
                       an_instance_of(XmlPatch::Operations::Remove).and(have_attributes(sel: '/foo/bar'))
                     ).ordered
      expect(doc).to have_received(:<<).with(
                       an_instance_of(XmlPatch::Operations::Remove).and(have_attributes(sel: '/baz/qux'))
                     ).ordered
    end
  end

  describe 'parse' do
    it 'does nothing when parsing the document yields nothing' do
      diff = XmlPatch::DiffDocument.new

      patch = instance_double(XmlPatch::XmlDocument)
      allow(patch).to receive(:parse)

      builder = described_class.new
      builder.parse(patch)

      expect(builder.diff_document).to eq(diff)
    end

    it 'does nothing when parsing the document yields unrecognised xml tags' do
      diff = XmlPatch::DiffDocument.new

      patch = instance_double(XmlPatch::XmlDocument)
      allow(patch).to receive(:parse).and_yield('foo', {})

      builder = described_class.new
      builder.parse(patch)

      expect(builder.diff_document).to eq(diff)
    end

    it 'calls remove for each remove tag yielded when parsing the document' do
      patch = instance_double(XmlPatch::XmlDocument)
      allow(patch).to receive(:parse)
        .and_yield('remove', 'sel' => '/foo/bar')
        .and_yield('remove', 'sel' => '/baz/qux')

      builder = described_class.new
      allow(builder).to receive(:remove)

      builder.parse(patch)

      expect(builder).to have_received(:remove).with('/foo/bar').ordered
      expect(builder).to have_received(:remove).with('/baz/qux').ordered
    end
  end
end
