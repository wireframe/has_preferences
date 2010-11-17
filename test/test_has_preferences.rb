require File.join(File.dirname(__FILE__), 'helper')

ActiveRecord::Schema.define(:version => 1) do
  create_table :users, :force => true do |t|
    t.column :preferences, :text
  end
end


class TestHasPreferences < Test::Unit::TestCase
  class User < ActiveRecord::Base
    has_preferences :owns_hat => false
  end

  context "object with boolean preference" do
    setup do
      @user = User.new
    end
    should 'default preference to false' do
      assert !@user.owns_hat?
    end
  end
end
