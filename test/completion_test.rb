require File.join(File.dirname(__FILE__), 'test_helper')

describe "Completion" do
  before_all { Bond.reset; Bond.debrief(:readline_plugin=>valid_readline_plugin); require 'bond/completion' }

  it "completes object methods anywhere" do
    matches = tabtab("blah :man.")
    matches.size.should.be > 0
    matches.should.be.all {|e| e=~ /^:man/}
  end

  it "completes global variables anywhere" do
    matches = tabtab("blah $-")
    matches.size.should.be > 0
    matches.should.be.all {|e| e=~ /^\$-/}
  end

  it "completes absolute constants anywhere" do
    tabtab("blah ::Arr").should == ["::Array"]
  end

  it "completes nested classes anywhere" do
    mock_irb
    tabtab("blah IRB::In").should == ["IRB::InputCompletor"]
  end

  it "completes symbols anywhere" do
    Symbol.expects(:all_symbols).returns([:mah])
    assert tabtab("blah :m").size > 0
  end

  it "completes string methods anywhere" do
    tabtab("blah 'man'.f").include?('.freeze').should == true
  end

  it "methods don't swallow up default completion" do
    Bond.agent.find_mission("Bond.complete(:method=>'blah') { Arr").should == nil
  end
end