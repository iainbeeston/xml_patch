require 'spec_helper'
require 'xml_patch/diff_document'
require 'xml_patch/operations/remove'

RSpec.describe XmlPatch do
  it 'has a version number' do
    expect(XmlPatch::VERSION).not_to be nil
  end

  describe 'apply...to' do
    it 'applies the patch to the xml' do
      patch = '<diff><remove sel="//foo" /></diff>'
      doc = '<bar><baz><foo /></baz><foo /></bar><foo />'
      expect(described_class.apply(patch).to(doc)).to eq('<bar><baz /></bar>')
    end
  end
end
