# -*- coding:utf-8-unix -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe Keyword do
  it "関連名は単数形の名前である必要がある" do
    lambda {
      Keyword.habto :image
    }.should_not raise_error
  end

  it "複数形の名前はエラー" do
    lambda {
      Keyword.habto :images
    }.should raise_error(ActiveRecord::ConfigurationError)
  end
end

