require 'spec_helper'

describe Fuse::Server, type: :feature do

  subject { page }

  before { visit '/' }

  its(:status_code) { should == 200 }
  it { should have_selector 'p', text: 'Hello!' }

  describe 'an empty folder' do

    before { visit '/?source=spec/fixtures/empty' }
    it { should have_content 'Couldn\'t determine source document. Please specify one with --source.' }

  end

  describe 'a folder with too many sources' do

    before { visit '/?source=spec/fixtures' }
    it { should have_selector 'h3', text: 'Choose source:' }
    it { should have_selector 'a',  text: 'html/document.html' }
    it { should have_selector 'a',  text: 'xml_and_xsl/document.xml' }

  end

end
