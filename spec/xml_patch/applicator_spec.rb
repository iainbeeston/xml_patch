require 'spec_helper'
require 'xml_patch/applicator'

RSpec.describe XmlPatch::Applicator do
  describe 'diff_xml' do
    it 'is the string passed to the constructor' do
      applicator = described_class.new('<remove sel="/foo/bar" />')
      expect(applicator.diff_xml).to eq('<remove sel="/foo/bar" />')
    end

    it 'cannot be mutated' do
      applicator = described_class.new('<remove sel="/foo/bar" />')
      expect {
        applicator.diff_xml.gsub!(/.*/, '')
      }.to raise_error(RuntimeError).with_message("can't modify frozen String")
    end

    it 'is not the same object that was passed to the constructor' do
      str = '<remove sel="/foo/bar" />'
      applicator = described_class.new(str)
      expect(applicator.diff_xml).not_to be(str)
    end
  end

  describe 'to' do
    it 'applies the diff passed to the constructor against the param of this method' do
      target_xml = '<foo><bar /></foo>'
      diff_xml = '<remove sel="/foo/bar" />'
      expect(described_class.new(diff_xml).to(target_xml)).to eq('<foo />')
    end
  end
end
