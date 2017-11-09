require 'spec_helper'
require 'xml_patch/applicator'
require 'xml_patch/xml_document'

RSpec.describe XmlPatch::Applicator do
  describe 'to' do
    it 'applies the diff passed to the constructor against the param of this method' do
      target_xml = '<foo><bar /></foo>'
      patch = XmlPatch::XmlDocument.new('<diff><remove sel="/foo/bar" /></diff>')
      expect(described_class.new(patch).to(target_xml)).to eq('<foo />')
    end
  end
end
