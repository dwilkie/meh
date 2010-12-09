require 'spec_helper'

describe "partnerships/index.html.haml" do
  before(:each) do
    assign(:partnerships, [
      stub_model(Partnership),
      stub_model(Partnership)
    ])
  end

  it "renders a list of partnerships" do
    render
  end
end
