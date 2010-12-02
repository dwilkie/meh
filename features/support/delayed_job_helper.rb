module DelayedJobHelper
  def find_job(name)
    found_job = nil
    Delayed::Job.all.each do |job|
      if job.name =~ name
        found_job = job
        break
      end
    end
    found_job
  end
end

World(DelayedJobHelper)

