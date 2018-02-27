require 'spec_helper'

describe "purchases/show.html.erb" do
  before(:each) do
    @purchase = assign(:purchase, stub_model(Purchase,
      :amount => "9.99",
      :tracking_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/9.99/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
