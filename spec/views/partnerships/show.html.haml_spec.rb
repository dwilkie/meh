require 'spec_helper'

describe "partnerships/show.html.haml" do
  before(:each) do
    @partnership = assign(:partnership, stub_model(Partnership))
  end

  it "renders attributes in <p>" do
    render
  end
end
