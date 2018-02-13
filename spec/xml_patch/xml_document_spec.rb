require 'spec_helper'
require 'xml_patch/xml_document'
require 'xml_patch/errors/invalid_xml'
require 'xml_patch/errors/invalid_xpath'

RSpec.describe XmlPatch::XmlDocument do
  describe 'to_xml' do
    it 'is the current state of the document' do
      doc = described_class.new('<foo><bar /></foo>')
      expect(doc.to_xml).to eq('<foo><bar /></foo>')
    end

    it 'raises an error if not given valid xml' do
      expect {
        described_class.new('<x:y:z></z>').to_xml
      }.to raise_error(XmlPatch::Errors::InvalidXml)
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

    it 'raises an error if the object is frozen' do
      doc = described_class.new('<foo><bar /></foo>')
      doc.freeze
      expect {
        doc.remove_at!('/foo/bar')
      }.to raise_error(RuntimeError).with_message("can't modify frozen XmlPatch::XmlDocument")
    end
  end

  describe 'replace_at!' do
    context 'given an xpath to an element' do
      it 'replaces all matching elements if the input is xml' do
        doc = described_class.new('<foo><bar /><bar /></foo>')
        doc.replace_at!('/foo/bar', '<baz />')
        expect(doc.to_xml).to eq('<foo><baz /><baz /></foo>')
      end

      it 'replaces all matching elements if the input is text' do
        doc = described_class.new('<foo><bar /><bar /></foo>')
        doc.replace_at!('/foo/bar', 'hello world')
        expect(doc.to_xml).to eq('<foo>hello worldhello world</foo>')
      end

      it 'removes all matching elements if the input nil' do
        doc = described_class.new('<foo><bar /><bar /></foo>')
        doc.replace_at!('/foo/bar', nil)
        expect(doc.to_xml).to eq('<foo />')
      end

      it 'does not change the xml if the element does not exist' do
        doc = described_class.new('<foo><bar /></foo>')
        doc.replace_at!('/bar', '<baz />')
        expect(doc.to_xml).to eq('<foo><bar /></foo>')
      end
    end

    context 'given an xpath to an attribute' do
      it 'replaces the attribute with the input from every matching parent element' do
        doc = described_class.new('<foo><bar a="hello world" /><bar a="fizz buzz" /></foo>')
        doc.replace_at!('/foo/bar/@a', 'new-new-new')
        expect(doc.to_xml).to eq('<foo><bar a="new-new-new" /><bar a="new-new-new" /></foo>')
      end

      it 'replaces the attribute with "" if the input is nil' do
        doc = described_class.new('<foo><bar a="hello world" /><bar a="fizz buzz" /></foo>')
        doc.replace_at!('/foo/bar/@a', nil)
        expect(doc.to_xml).to eq('<foo><bar a="" /><bar a="" /></foo>')
      end

      it 'does not change the xml if the attribute does not exist' do
        doc = described_class.new('<foo><bar a="hello world" /></foo>')
        doc.replace_at!('/foo/bar/@b', 'new-new-new')
        expect(doc.to_xml).to eq('<foo><bar a="hello world" /></foo>')
      end
    end

    xcontext 'given an xpath to a prefixed namespace declaration'

    context 'given an xpath to a comment' do
      it 'replaces the comment with the input' do
        doc = described_class.new('<foo><bar><!-- hello --><baz /><!-- world --></bar></foo>')
        doc.replace_at!('/foo/bar/comment()[2]', '<!-- new comment -->')
        expect(doc.to_xml).to eq('<foo><bar><!-- hello --><baz /><!-- new comment --></bar></foo>')
      end

      it 'replaces all comments if no index is given' do
        doc = described_class.new('<foo><bar><!-- hello --><baz /><!-- world --></bar></foo>')
        doc.replace_at!('/foo/bar/comment()', '<!-- new comment -->')
        expect(doc.to_xml).to eq('<foo><bar><!-- new comment --><baz /><!-- new comment --></bar></foo>')
      end

      it 'removes the comment if the input is nil' do
        doc = described_class.new('<foo><bar><!-- hello --><baz /><!-- world --></bar></foo>')
        doc.replace_at!('/foo/bar/comment()[2]', nil)
        expect(doc.to_xml).to eq('<foo><bar><!-- hello --><baz /></bar></foo>')
      end

      it 'does not change the xml if the comment does not exist' do
        doc = described_class.new('<foo><bar><!-- hello --><baz /><!-- world --></bar></foo>')
        doc.replace_at!('/foo/bar/comment()[3]', '<!-- new comment -->')
        expect(doc.to_xml).to eq('<foo><bar><!-- hello --><baz /><!-- world --></bar></foo>')
      end
    end

    xcontext 'given an xpath to a processing instruction'

    context 'given an xpath to text' do
      it 'replaces the specified text node with the input' do
        doc = described_class.new('<foo><bar>hello <baz /> world</bar></foo>')
        doc.replace_at!('/foo/bar/text()[2]', 'fizz buzz')
        expect(doc.to_xml).to eq('<foo><bar>hello <baz />fizz buzz</bar></foo>')
      end

      it 'replaces all text from the parent if no index is given' do
        doc = described_class.new('<foo><bar>hello <baz /> world</bar></foo>')
        doc.replace_at!('/foo/bar/text()', 'fizz buzz')
        expect(doc.to_xml).to eq('<foo><bar>fizz buzz<baz />fizz buzz</bar></foo>')
      end

      it 'removes the text if the input is nil' do
        doc = described_class.new('<foo><bar>hello <baz /> world</bar></foo>')
        doc.replace_at!('/foo/bar/text()[2]', nil)
        expect(doc.to_xml).to eq('<foo><bar>hello <baz /></bar></foo>')
      end

      it 'does not change the xml if the text does not exist' do
        doc = described_class.new('<foo><bar>hello <baz /> world</bar></foo>')
        doc.replace_at!('/foo/bar/text()[3]', 'fizz buzz')
        expect(doc.to_xml).to eq('<foo><bar>hello <baz /> world</bar></foo>')
      end
    end

    it 'raises an error if the object is frozen' do
      doc = described_class.new('<foo><bar /></foo>')
      doc.freeze
      expect {
        doc.replace_at!('/foo/bar', XmlPatch::XmlDocument.new('<baz />'))
      }.to raise_error(RuntimeError).with_message("can't modify frozen XmlPatch::XmlDocument")
    end
  end

  describe 'get_at' do
    it 'does not yield if the xpath cannot be found' do
      doc = described_class.new('<foo></foo>')
      expect { |b|
        doc.get_at('/bar', &b)
      }.to_not yield_control
    end

    it 'yields the name, attributes and content of each node at that xpath' do
      doc = described_class.new('<foo><bar x="A" /><bar x="B">hello world</bar></foo>')
      expect { |b|
        doc.get_at('/foo/bar', &b)
      }.to yield_successive_args([
        'bar', { 'x' => 'A' }, nil
      ], [
        'bar', { 'x' => 'B' }, an_instance_of(XmlPatch::XmlDocument).and(having_attributes(to_xml: 'hello world'))
      ])
    end

    it 'raises an error if the xpath is invalid' do
      doc = described_class.new('')
      expect {
        doc.get_at('//////////') {}
      }.to raise_error(XmlPatch::Errors::InvalidXpath)
    end

    it 'returns itself' do
      doc = described_class.new('')
      expect(doc.get_at('/')).to eq(doc)
    end
  end
end
