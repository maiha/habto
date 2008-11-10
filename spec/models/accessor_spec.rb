# -*- coding:utf-8-unix -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Image, Keyword do
  it "関連名 :images によって、image_count アクセサが定義される" do
    Keyword.new.should respond_to(:image_count)
  end

  it "関連名 :boards によって、board_count アクセサが定義される" do
    Keyword.new.should respond_to(:board_count)
  end
end

