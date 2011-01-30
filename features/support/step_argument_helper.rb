class << self
  def relative_reference
    "(?:the (\\d+)?(?:|st |th |nd |rd ))?most recent"
  end

  def relative_job
    relative_reference << " job in the queue"
  end

  def relative_outgoing_text_message
    relative_reference << " #{capture_model} destined for #{capture_model} should (not )?(be|include)"
  end
end

