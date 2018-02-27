require 'spec_helper'

describe "purchases/index.html.erb" do
  before(:each) do
    assign(:purchases, [
      stub_model(Purchase,
        :amount => "9.99",
        :tracking_id => 1
      ),
      stub_model(Purchase,
        :amount => "9.99",
        :tracking_id => 1
      )
    ])
  end

  it "renders a list of purchases" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
