require 'spec_helper'

describe Purchase do
  describe 'create' do
    it { Purchase.create!(amount: 100, tracking_id: 1) }
  end
end
