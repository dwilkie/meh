class PaymentApplication < ActiveRecord::Base

  PAYMENT_REQUEST_RESOURCE = "payment_requests"

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
        payment_application.verify! if
          self.class.post(payment_application.payment_request_uri).code == 200
      end
    end
  end

  class UriValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      begin
        uri = URI.parse(value)
        record.errors.add(attribute, :invalid) unless
          uri.scheme =~ /^https?$/
      rescue URI::InvalidURIError
        record.errors.add attribute, :invalid
      end
    end
  end

  belongs_to :seller,
             :class_name => "User"

  has_many   :payment_requests

  validates  :seller,
             :presence => true

  validates  :uri,
             :presence => true,
             :uri => true

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

  def payment_request_uri(options = {})
    path = PAYMENT_REQUEST_RESOURCE
    path = "#{path}/#{options[:remote_id]}" if options[:remote_id]
    request_uri = URI.join(uri, path)
    request_uri.query = options[:query].to_query if options[:query]
    request_uri.to_s
  end

end

