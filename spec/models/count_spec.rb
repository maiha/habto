# -*- coding:utf-8-unix -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Image, Keyword, "find_one" do
  fixtures :keywords, :images, :boards, :images_keywords, :boards_keywords

  ######################################################################
  ### :count => :nksk

  it "不明な関連名指定で ConfigurationError" do
    lambda {
      Keyword.find(@cute.id, :count=>:nksk)
    }.should raise_error(ActiveRecord::ConfigurationError)
  end

  ######################################################################
  ### :count => :images

  it ":count => :images の関連名指定で、image_count に4が設定される" do
    cute = Keyword.find(@cute.id, :count=>:images)
    cute.image_count.should == 4
    cute.image_ids.size.should == 4 # same as habtm
  end

  ######################################################################
  ### :count => :boards

  it ":count => :boards の関連名指定で、board_count に2が設定される" do
    cute = Keyword.find(@cute.id, :count=>:boards)
    cute.board_count.should == 2
    cute.board_ids.size.should == 2 # same as habtm
  end

  ######################################################################
  ### :count => [:boards, :images]

  it ":count => [:boards, :images] という複数の関連名指定も可能" do
    cute = Keyword.find(@cute.id, :count=>[:boards, :images])
    cute.image_count.should == 4
    cute.image_ids.size.should == 4 # same as habtm
    cute.board_count.should == 2
    cute.board_ids.size.should == 2 # same as habtm
  end

  ######################################################################
  ### :count => true

  it ":count => true で image_count に4が、board_count が2に一度に設定される" do
    cute = Keyword.find(@cute.id, :count=>true)
    cute.image_count.should == 4
    cute.image_ids.size.should == 4 # same as habtm
    cute.board_count.should == 2
    cute.board_ids.size.should == 2 # same as habtm
  end

  it ":count => true で image_count に0が、board_count が0に一度に設定される" do
    cute = Keyword.find(@buono.id, :count=>true)
    cute.image_count.should == 0
    cute.image_ids.size.should == 0 # same as habtm
    cute.board_count.should == 0
    cute.board_ids.size.should == 0 # same as habtm
  end

  ######################################################################
  ### null value

  it "属性値は '0'、アクセサの値は0を返す" do
    buono = Keyword.find(@buono.id, :count=>:images)
    buono[:image_count].should == '0'
    buono.image_count.should == 0
  end

  it "属性値は '0'、アクセサの値は0を返す (複数指定版)" do
    buono = Keyword.find(@buono.id, :count=>true)
    buono[:image_count].should == '0'
    buono.image_count.should == 0
    buono[:board_count].should == '0'
    buono.board_count.should == 0
  end

  it "条件説に image_count を利用できる" do
    buono = nil
    lambda {
      buono = Keyword.find(@buono.id, :count=>:images, :conditions=>"image_count = 0")
    }.should_not raise_error
    buono[:image_count].should == '0'
    buono.image_count.should == 0
  end

  it "order に image_count を利用できる" do
    lambda {
      Keyword.find(@buono.id, :count=>:images, :order=>"image_count")
    }.should_not raise_error
  end
end


describe Image, Keyword, "find_some" do
  fixtures :keywords, :images, :boards, :images_keywords, :boards_keywords

  ######################################################################
  ### :count => :images

  it ":count => :images の関連名指定で、image_count に値がそれぞれ設定される" do
    keywords = Keyword.find(:all, :count=>:images, :order=>:id)
    keywords.map(&:image_count).should == [4,1,0,0,0]
  end

  ######################################################################
  ### :order => :image_count

  it ":order => :image_count で default 値が適用される" do
    keywords = Keyword.find(:all, :count=>:images, :order=>"image_count DESC")
    keywords.map(&:image_count).should == [4,1,0,0,0]
  end
end

