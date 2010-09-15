class PaymentApplication < ActiveRecord::Base

  class VerifyPaymentApplicationJob < Struct.new(:id)
    include HTTParty

    attr_reader :attempt_job

    MAX_ATTEMPTS = 1

    def before(job)
      @attempt_job = job.attempts < MAX_ATTEMPTS
    end

    def perform
      if attempt_job
        payment_application = PaymentApplication.find(id)
        uri = URI.join(
          payment_application.uri,
          "payment_requests"
        ).to_s
        payment_application.verify! if
          self.class.post(uri).code == 200
      end
    end
  end

#  class UriValidator < ActiveModel::EachValidator
#    def validate_each(record, attribute, value)

#      unless record.user.category_ids.include?(value)
#        record.errors.add attribute, 'has bad category.'
#      end
#    end
#  end

  belongs_to :seller,
             :class_name => "User"

  validates  :seller,
             :presence => true

  validates  :uri,
             :presence => true
#             :uri => true

  after_save :verify_later!

  def unverified?
    verified_at.nil?
  end

  def verified?
    !unverified?
  end

  def verify_later!
    if uri_changed? && uri_was != uri
      self.update_attributes!(:verified_at => nil) if verified?
      Delayed::Job.enqueue(
        VerifyPaymentApplicationJob.new(self.id), 3
      )
    end
  end

  def verify!
    self.update_attributes!(:verified_at => Time.now)
  end

end

