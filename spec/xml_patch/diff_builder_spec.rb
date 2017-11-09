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

  describe 'replace' do
    it 'appends a replace operation to the diff document' do
      builder = described_class.new
      doc = builder.diff_document
      allow(doc).to receive(:<<)

      builder.replace('/foo/bar', 'hello world')
      builder.replace('/baz/qux', 'fizz buzz')

      expect(doc).to have_received(:<<).with(
        an_instance_of(XmlPatch::Operations::Replace).and(have_attributes(sel: '/foo/bar', content: 'hello world'))
      ).ordered
      expect(doc).to have_received(:<<).with(
        an_instance_of(XmlPatch::Operations::Replace).and(have_attributes(sel: '/baz/qux', content: 'fizz buzz'))
      ).ordered
    end
  end

  describe 'parse' do
    it 'only gets the nodes at /diff/* from the document' do
      patch = instance_double(XmlPatch::XmlDocument)
      allow(patch).to receive(:get_at)

      builder = described_class.new
      builder.parse(patch)

      expect(patch).to have_received(:get_at).with('/diff/*')
    end

    it 'does nothing when no xml tags are yielded by the document' do
      diff = XmlPatch::DiffDocument.new

      patch = instance_double(XmlPatch::XmlDocument)
      allow(patch).to receive(:get_at)

      builder = described_class.new
      builder.parse(patch)

      expect(builder.diff_document).to eq(diff)
    end

    it 'does nothing when parsing the document yields unrecognised xml tags' do
      diff = XmlPatch::DiffDocument.new

      patch = instance_double(XmlPatch::XmlDocument)
      allow(patch).to receive(:get_at).and_yield('foo', {})

      builder = described_class.new
      builder.parse(patch)

      expect(builder.diff_document).to eq(diff)
    end

    it 'calls remove for each remove tag yielded when parsing the document' do
      patch = instance_double(XmlPatch::XmlDocument)
      allow(patch).to receive(:get_at)
        .and_yield('remove', 'sel' => '/foo/bar')
        .and_yield('remove', 'sel' => '/baz/qux')

      builder = described_class.new
      allow(builder).to receive(:remove)

      builder.parse(patch)

      expect(builder).to have_received(:remove).with('/foo/bar').ordered
      expect(builder).to have_received(:remove).with('/baz/qux').ordered
    end

    it 'calls replace for each remove tag yielded when parsing the document' do
      patch = instance_double(XmlPatch::XmlDocument)
      allow(patch).to receive(:get_at)
        .and_yield('replace', 'sel' => '/foo/bar', 'content' => 'hello world')
        .and_yield('replace', 'sel' => '/baz/qux', 'content' => 'fizz buzz')

      builder = described_class.new
      allow(builder).to receive(:replace)

      builder.parse(patch)

      expect(builder).to have_received(:replace).with('/foo/bar', 'hello world').ordered
      expect(builder).to have_received(:replace).with('/baz/qux', 'fizz buzz').ordered
    end
  end
end
