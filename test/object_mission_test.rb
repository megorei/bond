require File.join(File.dirname(__FILE__), 'test_helper')

class Bond::ObjectMissionTest < Test::Unit::TestCase
  before(:all) {|e| Bond.debrief(:readline_plugin=>valid_readline_plugin) }
  before(:each) {|e| Bond.agent.reset }
  context "object mission" do
    test "with default action completes" do
      Bond.complete(:object=>"String")
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.u").should == [".upcase!", ".unpack", ".untaint", ".upcase", ".upto"]
    end

    test "with regex condition completes" do
      Bond.complete(:object=>/Str/) {|e| e.object.class.superclass.instance_methods(true) }
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.u").should == [".untaint"]
    end

    test "with explicit action completes" do
      Bond.complete(:object=>"String") {|e| e.object.class.superclass.instance_methods(true) }
      Bond.complete(:on=>/man/) { %w{upper upster upful}}
      complete("'man'.u").should == [".untaint"]
    end

    test "completes without including word break characters" do
      Bond.complete(:object=>"Hash")
      matches = complete("{}.f")
      assert matches.size > 0
      matches.all? {|e| !e.include?('{')}.should == true
    end

    test "completes nil, false and range objects" do
      Bond.complete(:object=>"Object")
      assert complete("nil.f").size > 0
      assert complete("false.f").size > 0
      assert complete("(1..10).f").size > 0
    end

    test "completes hashes and arrays with spaces" do
      Bond.complete(:object=>"Object")
      assert complete("[1, 2].f").size > 0
      assert complete("{:a =>1}.f").size > 0
    end

    test "ignores invalid invalid ruby" do
      Bond.complete(:object=>"String")
      complete("blah.upt").should == []
    end

    # needed to ensure Bond works in irbrc
    test "doesn't evaluate irb binding on definition" do
      Object.expects(:const_defined?).never
      Bond.complete(:object=>"String")
    end

    test "sets binding to toplevel binding when not in irb" do
      Object.expects(:const_defined?).with(:IRB).returns(false)
      mission = Bond::Mission.create(:object=>'Symbol')
      mission.class.expects(:eval).with(anything, ::TOPLEVEL_BINDING)
      mission.matches?(':ok.')
    end
  end
end