require 'spec_helper'

describe Post do
  describe 'create' do
    it { Post.create!(title: 'Testing!') }
  end
end
