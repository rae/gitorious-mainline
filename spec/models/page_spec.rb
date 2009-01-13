#--
#   Copyright (C) 2009 Johan Sørensen <johan@johansorensen.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

require File.dirname(__FILE__) + '/../spec_helper'
require "fileutils"

describe Page do
  before(:each) do
    @path = "/tmp/gts-test-wiki"
    delete_test_repo
    FileUtils.mkdir(@path)
    Dir.chdir(@path) do
      File.open("HowTo.textile", "wb"){|f| f.puts "Hello world!" }
      `git init; git add .; git commit --author='Johan Sorensen <johan@johansorensen.com>' -m "first commit"`
    end
    @repo = Grit::Repo.new(@path)
  end
  
  after(:each) { delete_test_repo }
  
  it "finds an existing page" do
    page = Page.find("HowTo", @repo)
    page.new?.should == false
    page.name.should == "HowTo.textile"
    page.content.should == "Hello world!\n"
  end
  
  it "raises an error when there's no user set" do
    p = Page.find("HowTo", @repo)
    proc{ p.save }.should raise_error(Page::UserNotSetError)
  end
  
  it "updates the content when calling save" do
    p = Page.find("HowTo", @repo)
    p.user = users(:johan)
    p.content = "bye cruel world!"
    p.content.should == "bye cruel world!"
    p.save.should match(/^[a-z0-9]{40}$/)
    p2 = Page.find("HowTo", @repo)
    p2.content.should == "bye cruel world!"
  end
  
  it "creates a new page" do
    p = Page.find("Hello", @repo)
    p.new?.should == true
    p.content.should == ""
    p.user = users(:johan)
    p.save.should match(/^[a-z0-9]{40}$/)
    Page.find("Hello", @repo).new?.should == false
    Page.find("HowTo", @repo).new?.should == false
  end
  
  it "supports nested pages" do
    p = Page.find("Hello/World", @repo)
    p.new?.should == true
    p.name.should == "Hello/World.textile"
    p.content = "foo"
    p.user = users(:johan)
    p.save.should match(/^[a-z0-9]{40}$/)
    
    p2 = Page.find("Hello/World", @repo)
    p2.new?.should == false
  end
  
  it "has a basename without the extension" do
    p = Page.find("HowTo", @repo)
    p.title.should == "HowTo"
    
    p.to_param.should == p.title
  end
  
  it "should have a commit" do
    p = Page.find("HowTo", @repo)
    p.commit.should be_instance_of(Grit::Commit)
    p.commit.committer.email.should == "johan@johansorensen.com"
    p.commit.message.should == "first commit"
    
    p2 = Page.find("somethingnew", @repo)
    p2.new?.should == true
    p2.commit.should == nil
  end
  
  it "should have a committed by user" do
    p = Page.find("HowTo", @repo)
    p.committed_by_user.should == users(:johan)
  end
  
  def delete_test_repo
    FileUtils.rm_rf(@path) if File.exist?(@path)
  end
  
end
