require 'spec_helper'

describe Fuse::Document::Asset do

  describe 'circular dependents' do

    it 'should raise on sort' do
      expect { Fuse::Document::Asset['spec/fixtures/circular_dependents'].sort }.to raise_error(Fuse::Exception::CircularDependency)
    end

  end

end