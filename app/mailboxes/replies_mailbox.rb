class RepliesMailbox < ApplicationMailbox
  MATCHER = /reply-(.+)@reply.example.com/i
  # mail => Mail.object
  # inbound_email => ActionMailbox::InboundEmail record
  # before_processing :ensure_user

  def process
    # load user records from the database
    return if user.nil?

    discussion.comments.create(
      user: user,
      body: mail.decoded
    )
  end

  def user
    @user ||= User.find_by(email: mail.from)
  end

  def discussion
    @discussion ||= Discussion.find(discussion_id)
  end

  def discussion_id
    recipient = mail.recipients.find{ |r| MATCHER.match?(r) }
    recipient[MATCHER, 1]
    # String#[] method https://medium.com/rubycademy/3-ways-to-use-regexp-capture-groups-with-back-references-in-ruby-b4969cc9b3ec
  end

  def ensure_user
    bounce_with UserMailer.missing(inbound_email) if user.nil?
  end
end
