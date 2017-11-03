require 'spec_helper'
require 'xml_patch/xml_document'
require 'xml_patch/errors/invalid_xml'
require 'xml_patch/errors/invalid_xpath'

RSpec.describe XmlPatch::XmlDocument do
  describe 'new' do
    it 'raises an error if not given valid xml' do
      expect {
        described_class.new('<x:y:z></z>')
      }.to raise_error(XmlPatch::Errors::InvalidXml)
    end
  end

  describe 'to_xml' do
    it 'is the current state of the document' do
      doc = described_class.new('<foo><bar /></foo>')
      expect(doc.to_xml).to eq('<foo><bar /></foo>')
    end
  end

  describe 'remove_at!' do
    context 'given an xpath to an element' do
      it 'removes all matching elements from the document' do
        doc = described_class.new('<foo><bar /><bar /></foo>')
        doc.remove_at!('/foo/bar')
        expect(doc.to_xml).to eq('<foo />')
      end

      it 'does not change the xml if the element does not exist' do
        doc = described_class.new('<foo><bar /></foo>')
        doc.remove_at!('/bar')
        expect(doc.to_xml).to eq('<foo><bar /></foo>')
      end
    end

    context 'given an xpath to an attribute' do
      it 'removes the attribute from every matching parent element' do
        doc = described_class.new('<foo><bar a="hello world" /><bar a="fizz buzz" /></foo>')
        doc.remove_at!('/foo/bar/@a')
        expect(doc.to_xml).to eq('<foo><bar /><bar /></foo>')
      end

      it 'does not change the xml if the attribute does not exist' do
        doc = described_class.new('<foo><bar a="hello world" /></foo>')
        doc.remove_at!('/foo/bar/@b')
        expect(doc.to_xml).to eq('<foo><bar a="hello world" /></foo>')
      end
    end

    xcontext 'given an xpath to a prefixed namespace declaration'

    context 'given an xpath to a comment' do
      it 'removes the comment from the parent element' do
        doc = described_class.new('<foo><bar><!-- hello --><baz /><!-- world --></bar></foo>')
        doc.remove_at!('/foo/bar/comment()[2]')
        expect(doc.to_xml).to eq('<foo><bar><!-- hello --><baz /></bar></foo>')
      end

      it 'does not change the xml if the comment does not exist' do
        doc = described_class.new('<foo><bar><!-- hello --><baz /><!-- world --></bar></foo>')
        doc.remove_at!('/foo/bar/comment()[3]')
        expect(doc.to_xml).to eq('<foo><bar><!-- hello --><baz /><!-- world --></bar></foo>')
      end
    end

    xcontext 'given an xpath to a processing instruction'

    context 'given an xpath to text' do
      it 'removes the specified text node from the parent element' do
        doc = described_class.new('<foo><bar>hello <baz /> world</bar></foo>')
        doc.remove_at!('/foo/bar/text()[2]')
        expect(doc.to_xml).to eq('<foo><bar>hello <baz /></bar></foo>')
      end

      it 'removes all text from the parent if no index is given' do
        doc = described_class.new('<foo><bar>hello <baz /> world</bar></foo>')
        doc.remove_at!('/foo/bar/text()')
        expect(doc.to_xml).to eq('<foo><bar><baz /></bar></foo>')
      end

      it 'does not change the xml if the text does not exist' do
        doc = described_class.new('<foo><bar>hello <baz /> world</bar></foo>')
        doc.remove_at!('/foo/bar/text()[3]')
        expect(doc.to_xml).to eq('<foo><bar>hello <baz /> world</bar></foo>')
      end
    end

    context 'given an invalid xpath' do
      it 'raises an error' do
        doc = described_class.new('')
        expect {
          doc.remove_at!('//////////')
        }.to raise_error(XmlPatch::Errors::InvalidXpath)
      end
    end
  end
end
