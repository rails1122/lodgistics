require "test_helper"

class MentionTest < ActiveSupport::TestCase
  let(:mention) { create(:mention) }
  let(:chat_message_mention) { create(:mention) }
  let(:feed_post) { create(:engage_message) }
  let(:feed_post_mention) { create(:mention, mentionable: feed_post) }

  it 'default status is not_checked' do
    mention.status.must_equal 'not_checked'
  end

  describe "#notification_msg" do
    it do
      mentioned_user_names_with_at_sign = chat_message_mention.mentioned_users.map { |i| "@#{i.name}" }.join(" ")
      assert(chat_message_mention.notification_msg == "#{chat_message_mention.created_by.name} mentioned you:\n#{mentioned_user_names_with_at_sign} #{chat_message_mention.mentionable.message}")
    end

    it do
      mentioned_user_names_with_at_sign = feed_post_mention.mentioned_users.map { |i| "@#{i.name}" }.join(" ")
      assert(feed_post_mention.notification_msg == "#{feed_post_mention.created_by.name} mentioned you:\n#{mentioned_user_names_with_at_sign} #{feed_post_mention.mentionable.body}")
    end
  end

  describe "snoozed?" do
    it do
      assert(mention.snoozed_at.nil?)
      assert(mention.snoozed? == false)
      now = DateTime.now
      Timecop.freeze(now)
      mention.set_snooze
      mention.reload
      assert(mention.snoozed_at.present?)
      assert(mention.snoozed? == true)
      Timecop.freeze(now + 4.hours)
      assert(mention.snoozed? == true)
      Timecop.freeze(now + 4.hours + 1.second)
      assert(mention.snoozed? == false)
      Timecop.return
    end
  end

  describe 'snoozed_only' do
    it do
      now = DateTime.now
      Timecop.freeze(now)
      mention_1 = create(:mention)
      mention_2 = create(:mention, snoozed_at: 3.hour.ago)
      mention_3 = create(:mention, snoozed_at: 4.hour.ago)
      mention_4 = create(:mention, snoozed_at: 5.hour.ago)
      assert(Mention.snoozed_only == [ mention_2, mention_3 ])
      Timecop.return
    end
  end

  describe 'unsnoozed_only' do
    it do
      now = DateTime.now
      Timecop.freeze(now)
      mention_1 = create(:mention)
      mention_2 = create(:mention, snoozed_at: 3.hour.ago)
      mention_3 = create(:mention, snoozed_at: 4.hour.ago)
      mention_4 = create(:mention, snoozed_at: 5.hour.ago)
      assert(Mention.unsnoozed_only == [ mention_1, mention_4 ])
      Timecop.return
    end
  end

end
