require 'spec_helper'

StyleSheet = Fuse::Document::Asset::StyleSheet

describe StyleSheet do

  describe 'conditional comments' do

    {
        'style1 (screen,projection).css'=> 'x',
        'style2 (screen) (!ie).css'     => '<!--[if !IE]> -->x<!-- <![endif]-->',
        'style3 (ie6) (all).css'        => '<!--[if IE 6]>x<![endif]-->',
        'style4 (lte ie6) (print).css'  => '<!--[if lte IE 6]>x<![endif]-->',
        'style5 (gt ie 6).css'          => '<!--[if gt IE 6]>x<![endif]-->',

    }.each do |path, wrapped|

      specify "Path #{path} should produce content #{wrapped}" do
        sheet = StyleSheet.new(path, '.')
        sheet.conditional.wrap('x').should == wrapped
      end

    end

  end

end