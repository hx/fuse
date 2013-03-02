# coding: utf-8

require 'spec_helper'

describe Fuse::Document do

  let(:options) { Fuse::DEFAULTS[:common].merge Fuse::DEFAULTS[:server] }
  subject { Fuse::Document.new(options) }

  describe 'Source determination' do

    describe 'With an empty directory' do

      before { options[:source] = 'spec/fixtures/empty' }
      it 'should raise SourceUnknown' do
        expect { subject }.to raise_exception(Fuse::Exception::SourceUnknown)
      end

    end

    describe 'With a nonexistent file' do

      before { options[:source] = 'a/nonexistent/file' }

      it 'should raise NotFound' do
        expect { subject }.to raise_exception(Fuse::Exception::SourceUnknown::NotFound)
      end


    end

    describe 'XML with XSL' do

      before do
        options[:source] = 'spec/fixtures/xml_and_xsl/document.xml'
        options[:encoding] = 'utf-8'
      end
      its(:source_path) { should == 'spec/fixtures/xml_and_xsl/document.xml' }
      its(:xsl_path)    { should == 'spec/fixtures/xml_and_xsl/template.xsl' }
      its(:to_s)        { should include '<p>“Child 2”</p>' }

      describe 'with a dir' do
        before { options[:source] = 'spec/fixtures/xml_and_xsl' }
        its(:source_path) { should == 'spec/fixtures/xml_and_xsl/document.xml' }
        its(:xsl_path)    { should == 'spec/fixtures/xml_and_xsl/template.xsl' }
      end

      describe 'with a dir and template' do
        before do
          options[:source] = 'spec/fixtures/xml_and_xsl'
          options[:xsl] = 'spec/fixtures/xml_and_xsl/template.xsl'
        end
        its(:source_path) { should == 'spec/fixtures/xml_and_xsl/document.xml' }
        its(:xsl_path)    { should == 'spec/fixtures/xml_and_xsl/template.xsl' }
      end

      describe 'with a dir and nonexistent template' do
        before do
          options[:source] = 'spec/fixtures/xml_and_xsl'
          options[:xsl] = 'a/nonexistent/template.xsl'
        end
        it 'should raise SourceUnknown' do
          expect { subject }.to raise_exception(Fuse::Exception::SourceUnknown)
        end
      end

    end

    describe 'HTML' do

      before { options[:source] = 'spec/fixtures/html' }
      its(:source_path) { should == 'spec/fixtures/html/document.html' }
      its(:xsl_path)    { should be_nil }

      describe 'output' do

        subject { Fuse::Document.new(options).to_s }
        it { should include '<p>Hello!</p>' }

        describe 'with a title' do
          before { options[:title] = 'This & that!' }
          it { should include '<title>This &amp; that!</title>' }
        end

      end

      describe 'stylesheets (referenced)' do
        before { options[:embed_assets] = false }
        subject { Nokogiri::HTML(Fuse::Document.new(options).to_s).css('> html > head > link[rel=stylesheet]') }
        its(:length) { should == 2 }
        it 'should reference style2, then style1 as per style1\'s "require" directive' do
          subject[0]['href'].should == 'style2.css'
          subject[1]['href'].should == 'style1.css'
        end
      end

      describe 'a specific file' do
        before { options[:source] = 'spec/fixtures/html/document.html' }
        its(:source_path) { should == 'spec/fixtures/html/document.html' }
      end

    end

  end

end
