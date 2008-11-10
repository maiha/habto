# -*- coding:utf-8-unix -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Keyword do
  fixtures :keywords

  it "通常は readonly にならない (AR準拠)" do
    keyword = Keyword.find(:first)
    keyword.readonly?.should == false
  end

  it ":count を指定しても、readonly にならない" do
    keyword = Keyword.find(:first, :count=>true)
    keyword.readonly?.should == false
  end

  it ":readonly を指定すると、readonly になる (AR準拠)" do
    keyword = Keyword.find(:first, :readonly=>true)
    keyword.readonly?.should == true
  end

  it ":count と :readonly を指定すると、readonly になる" do
    keyword = Keyword.find(:first, :count=>true, :readonly=>true)
    keyword.readonly?.should == true
  end

  it ":joins を指定すると、readonly になる (AR準拠)" do
    keyword = Keyword.find(:first, :joins=>"-- \n")
    keyword.readonly?.should == true
  end

  it ":joins と :count を指定すると、readonly になる" do
    keyword = Keyword.find(:first, :joins=>"-- \n", :count=>true)
    keyword.readonly?.should == true
  end
end

