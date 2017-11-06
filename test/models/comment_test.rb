require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # Setup Factories and Default Post
  FactoryBot.define do
    factory :comment do
      content "Woo! This is a test comment!"
      user
      post
    end
  end

  def setup
    @comment = build(:comment)
  end

  # Default Comment is valid
  test "comment should be valid" do
    assert @comment.valid?
  end

  # Tests presence validation
  test "content must be present" do
    @comment.content = nil
    assert_not @comment.valid?
  end

  # Tests length validation
  test "comment can not be too long" do
    @comment.content = "A" * 251
    assert_not @comment.valid?
  end

  test "comment can not be empty" do
    @comment.content = "  "
    assert_not @comment.valid?
  end

  # Test dependent destruction and associations
  test "dependent destruction and associations" do
    skip("Incomplete")
  end
end
