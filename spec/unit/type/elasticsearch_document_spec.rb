require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_document) do
  let(:resource_name) { 'a/b/c' }

  include_examples 'REST API types', 'document', :content

  describe 'document attribute validation' do
    it 'should have a source parameter' do
      expect(described_class.attrtype(:source)).to eq(:param)
    end

    describe 'content and source validation' do
      it 'should require either "content" or "source"' do
        expect do
          described_class.new(
            :name => resource_name,
            :ensure => :present
          )
        end.to raise_error(Puppet::Error, /content.*or.*source.*required/)
      end

      it 'should fail with both defined' do
        expect do
          described_class.new(
            :name => resource_name,
            :content => {},
            :source => 'puppet:///example.json'
          )
        end.to raise_error(Puppet::Error, /simultaneous/)
      end

      it 'should parse source paths into the content property' do
        file_stub = 'foo'
        [
          Puppet::FileServing::Metadata,
          Puppet::FileServing::Content
        ].each do |klass|
          allow(klass).to receive(:indirection)
            .and_return(Object)
        end
        allow(Object).to receive(:find)
          .and_return(file_stub)
        allow(file_stub).to receive(:content)
          .and_return('{"template":"foobar-*", "order": 1}')
        expect(described_class.new(
          :name => resource_name,
          :source => '/example.json'
        )[:content]).to include(
          'template' => 'foobar-*',
          'order' => 1
        )
      end
    end
    describe 'document name validation' do
      it 'must not just contain index and doc id or type' do
        expect do
          described_class.new(
            :name => 'a/b',
            :ensure => :present
          )
        end.to raise_error(Puppet::Error, %r{name must be of form <index>/<type>/<id>})
      end
      it 'must not specify a path deeper than index/type/doc' do
        expect do
          described_class.new(
            :name => 'a/b/c/d',
            :ensure => :present
          )
        end.to raise_error(Puppet::Error, %r{name must be of form <index>/<type>/<id>})
      end
      it 'must not start with a slash' do
        expect do
          described_class.new(
            :name => '/a/b/c',
            :ensure => :present
          )
        end.to raise_error(Puppet::Error, %r{name must be of form <index>/<type>/<id>})
      end
    end
  end # of describing when validing values
end # of describe Puppet::Type
