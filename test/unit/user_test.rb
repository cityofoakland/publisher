require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "creating a transaction with the initial details creates a valid transaction" do
    user = User.create(:name => "bob")
    without_panopticon_validation do
      trans = user.create_publication(:transaction, :name => "test", :slug => "test")
      assert trans.valid?
    end
  end

  test "it doesn't try to send a fact check email if no addresses were given" do
    user = User.create(:name => "bob")
    NoisyWorkflow.expects(:request_fact_check).never
    without_panopticon_validation do
      trans = user.create_publication(:transaction, :name => "test", :slug => "test")
      assert ! user.send_fact_check(trans.editions.last, {comment: "Hello"})
    end
  end

  test "user can't okay a publication they've sent for review" do
    user = User.create(:name => "bob")

    without_panopticon_validation do
      trans = user.create_publication(:transaction, :name => "test", :slug => "test")
      user.request_review(trans.editions.last, {comment: "Hello"})
      assert ! user.approve_review(trans.editions.last, {comment: "Hello"})
    end
  end

  test "user can't send back a publication they've sent for review" do
    user = User.create(:name => "bob")

    trans = user.create_publication(:transaction, :name => "test", :slug => "test")
    user.start_work(trans.editions.last)
    user.request_review(trans.editions.last, {comment: "Hello"})
    assert ! user.request_amendments(trans.editions.last, {comment: "Hello"})
  end

  test "when an user publishes a guide, a status message is sent on the message bus" do
    user = User.create(:name => "bob")
    second_user = User.create(:name => "dave")

    trans = user.create_publication(:transaction, :name => "test", :slug => "test")
    user.start_work(trans.editions.last)
    user.request_review(trans.editions.last, {comment: "Hello"})
    second_user.approve_review(trans.editions.last, {comment: "Hello"})

    Messenger.instance.expects(:published).with(trans).once
    user.publish trans.editions.last, {comment: "Published because I did"}
  end

  test "Edition becomes assigned to user when user is assigned an edition" do
    boss_user = User.create(:name => "Mat")
    worker_user = User.create(:name => "Grunt")

    publication = boss_user.create_publication(:answer, :name => "test answer", :slug => "test")
    boss_user.assign(publication.latest_edition, worker_user)
    publication.save
    publication.reload

    assert_equal(worker_user, publication.latest_edition.assigned_to)
  end

end
