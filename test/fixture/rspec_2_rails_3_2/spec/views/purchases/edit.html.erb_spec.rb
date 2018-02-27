require 'spec_helper'

describe "purchases/edit.html.erb" do
  before(:each) do
    @purchase = assign(:purchase, stub_model(Purchase,
      :new_record? => false,
      :amount => "9.99",
      :tracking_id => 1
    ))
  end

  it "renders the edit purchase form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => purchase_path(@purchase), :method => "post" do
      assert_select "input#purchase_amount", :name => "purchase[amount]"
      assert_select "input#purchase_tracking_id", :name => "purchase[tracking_id]"
    end
  end
end
