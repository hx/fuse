require 'spec_helper'

describe Fuse::Document do

  subject { Fuse::Document.new(options) }

  describe 'Source determination' do

    describe 'With an empty directory' do

      let(:options) {{ source: 'spec/fixtures/empty' }}
      it 'should raise SourceUnknown' do
        expect { subject }.to raise_exception(Fuse::Exception::SourceUnknown)
      end

    end

    describe 'With a nonexistent file' do

      let(:options) {{ source: 'a/nonexistent/file' }}

      it 'should raise NotFound' do
        expect { subject }.to raise_exception(Fuse::Exception::SourceUnknown::NotFound)
      end


    end

    describe 'XML with XSL' do

      describe 'with a dir' do
        let(:options) {{ source: 'spec/fixtures/xml_and_xsl' }}
        its(:source_path) { should == 'spec/fixtures/xml_and_xsl/document.xml' }
        its(:xsl_path)    { should == 'spec/fixtures/xml_and_xsl/template.xsl' }
      end

      describe 'with just an xml doc)' do
        let(:options) {{ source: 'spec/fixtures/xml_and_xsl/document.xml'}}
        its(:source_path) { should == 'spec/fixtures/xml_and_xsl/document.xml' }
        its(:xsl_path)    { should == 'spec/fixtures/xml_and_xsl/template.xsl' }
      end

      describe 'with a dir and template' do
        let(:options) {{ source: 'spec/fixtures/xml_and_xsl', xsl: 'spec/fixtures/xml_and_xsl/template.xsl' }}
        its(:source_path) { should == 'spec/fixtures/xml_and_xsl/document.xml' }
        its(:xsl_path)    { should == 'spec/fixtures/xml_and_xsl/template.xsl' }
      end

      describe 'with a dir and nonexistent template' do
        let(:options) {{ source: 'spec/fixtures/xml_and_xsl', xsl: 'a/nonexistent/template.xsl' }}
        it 'should raise SourceUnknown' do
          expect { subject }.to raise_exception(Fuse::Exception::SourceUnknown)
        end
      end

    end

    describe 'HTML' do

      let(:options) {{ source: 'spec/fixtures/html' }}
      its(:source_path) { should == 'spec/fixtures/html/document.html' }
      its(:xsl_path)    { should be_nil }

      describe 'file' do
        let(:options) {{ source: 'spec/fixtures/html/document.html' }}
        its(:source_path) { should == 'spec/fixtures/html/document.html' }
        its(:xsl_path)    { should be_nil }
      end

    end

  end

end
