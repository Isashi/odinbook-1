require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Setup Factories and Default User
  FactoryBot.define do
    sequence :email do |n|
      "example#{n}@example.com"
    end

    factory :user do
      email { generate(:email) }
      first_name "Jonathan"
      last_name "Yiv"
      password "password"
    end
  end

  def setup
    @user = build(:user)
  end

  # Default User is valid
  test "user should be valid" do
    assert @user.valid?
  end

  # Tests presence validation
  test "password must be present" do
    @user.password = nil
    assert_not @user.valid?
  end

  test "email must be present" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "first name must be present" do
    @user.first_name = nil
    assert_not @user.valid?
  end

  test "last name must be present" do
    @user.last_name = nil
    assert_not @user.valid?
  end

  # Tests length validation
  test "password should not be too short" do
    @user.password = "a"
    assert_not @user.valid?
  end

  test "first name should not be too short" do
    @user.first_name = "a"
    assert_not @user.valid?
  end

  test "first name should not be too long" do
    @user.first_name = "a" * 41
    assert_not @user.valid?
  end

  test "last name should not be too short" do
    @user.last_name = "a"
    assert_not @user.valid?
  end

  test "last name should not be too long" do
    @user.last_name = "a" * 41
    assert_not @user.valid?
  end

  # Tests format validation
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.com A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  # Test uniqueness validation
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  # Test downcase_email filter
  test "email addresses should be saved as lower-case" do
    mixed_case_email = 'Foo@ExAMPLe.coM'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # Test User/Post, User/Like, User/Comment, and User/Friendship dependent destruction
  test "destroying user destroys associated posts" do
    @user.save
    assert_difference 'Post.count', 1 do
      create(:post, user: @user)
    end
    assert_difference 'Post.count', -1 do
      @user.destroy
    end
  end

  test "destroying user destroys associated likes" do
    @user.save
    assert_difference 'Like.count', 1 do
      create(:like, user: @user)
    end
    assert_difference 'Like.count', -1 do
      @user.destroy
    end
  end

  test "destroying user destroys associated comments" do
    @user.save
    assert_difference 'Comment.count', 1 do
      create(:comment, user: @user)
    end
    assert_difference 'Comment.count', -1 do
      @user.destroy
    end
  end

  test "destroying user destroys associated friendship requests" do
    @user.save
    assert_difference 'Friendship.count', 2 do
      create(:friendship, requester: @user)
      create(:friendship, requested: @user)
    end
    assert_difference 'Friendship.count', -2 do
      @user.destroy
    end
  end

  test "destroying user destroys associated friendships" do
    @user.save
    assert_difference 'Friendship.where(accepted: true).count', 2 do
      create(:friendship, requester: @user, accepted: true)
      create(:friendship, requested: @user, accepted: true)
    end
    assert_difference 'Friendship.where(accepted: true).count', -2 do
      @user.destroy
    end
  end

  # Test friends method
  test "friends returns all friends" do
    @user.save
    create(:friendship, requester: @user, accepted: true)
    create(:friendship, requested: @user, accepted: true)
    create(:friendship, requested: @user, accepted: false)
    create(:friendship, requester: @user, accepted: false)
    assert_equal @user.friends.count, 2
  end
end
