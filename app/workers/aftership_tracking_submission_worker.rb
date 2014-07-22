class AftershipTrackingSubmissionWorker
	include Sidekiq::Worker if defined?(Sidekiq::Worker)
  def perform(id)
    AftershipTracking.find(id).exec_add_to_aftership
  end
end