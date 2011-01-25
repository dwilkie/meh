class << self
  def relative_reference
    "(?:the(?: (\d+))?(?:|st |th |nd |rd ))? most recent"
  end

  def relative_job
    relative_reference << " job in the queue"
  end
end

