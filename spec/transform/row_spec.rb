require 'spec_helper'

describe Transform::Row do
  describe '#method_missing' do
    it 'calls the field value' do
      Transform::Row.new([1,2,3], [:a, :b, :c]).b.should == 2
    end

    it 'raise error' do
      expect {Transform::Row.new([1], [:a]).b}.to raise_error(NoMethodError)
    end
  end

  describe '#to_s' do
    it 'converts to string' do
      Transform::Row.new([1,2,3], [:a, :b, :c]).to_s.should == '1,2,3'
    end
  end
end