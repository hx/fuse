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

      describe 'stylesheet media (referenced)' do
        before { options[:embed_assets] = false }
        subject { Nokogiri::HTML(Fuse::Document.new(options).to_s).css('> html > head > link[rel=stylesheet]') }
        it 'should reflect media specified in file names' do
          subject[0]['media'].should be_nil
          subject[1]['media'].should == 'all'
          subject[2]['media'].should == 'projection, screen'
        end
      end

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

      describe 'embedded assets' do
        before do
          options[:embed_assets] = true
          options[:compress_assets] = true
        end
        #noinspection RubyResolve
        its(:to_s) do
          should include '12px/14px Arial'
          should include 'padding:0'
          should include 'Hello from Script 1'
          should include 'Hello from Script 2'
          should include 'url(data:image/png;base64,MTIz)'
          should include '<img src="data:image/jpeg;base64,NDU2"'
          should include 'url(data:image/gif;base64,Nzg5)"></div>'
          should include '<link rel="shortcut icon" href="data:image/x-icon;base64,eHl6">'
        end
      end

      describe 'a specific file' do
        before { options[:source] = 'spec/fixtures/html/document.html' }
        its(:source_path) { should == 'spec/fixtures/html/document.html' }
      end

    end

  end

  describe 'assets whose filenames start with a dot' do
    before do
      options[:source] = 'spec/fixtures/dotfile_assets'
      options[:embed_assets] = false
    end
    subject { Nokogiri::HTML(Fuse::Document.new(options).to_s) }
    it 'should have no stylesheets or scripts' do
      subject.css('> html > head > link[rel=stylesheet]').should be_empty
      subject.css('> html > head > script[src]').should be_empty
    end
  end

  describe 'ie conditional comments' do
    before do
      options[:source] = 'spec/fixtures/ie'
      options[:embed_assets] = true
    end
    subject { Fuse::Document.new(options).to_s }
    it { should include '<!--[if !IE]> --><style type="text/css">*{content: "NOT IE"}</style>' + "\n" + '<!-- <![endif]-->' }
    it { should include '<!--[if IE 6]><style type="text/css">*{content: "= IE 6"}</style><![endif]-->' }
    it { should include '<!--[if lte IE 8]><style type="text/css" media="print">*{content: "<= IE 8"}</style><![endif]-->' }
    it { should include '<!--[if gt IE 8]><style type="text/css" media="screen">*{content: "> IE 8"}</style><![endif]-->' }
  end

end
