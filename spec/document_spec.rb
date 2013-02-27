require 'spec_helper'

describe Fuse::Document do

  describe 'XML with XSD' do

    subject { Fuse::Document.new(source: 'spec/fixtures/xml_and_xsl') }

    its(:source_path) { should == 'spec/fixtures/xml_and_xsl/document.xml' }
    its(:xsl_path)    { should == 'spec/fixtures/xml_and_xsl/template.xsl' }

  end

end
