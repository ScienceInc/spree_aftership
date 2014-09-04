class AftershipTrackingSubmissionWorker
	include Sidekiq::Worker if defined?(Sidekiq::Worker)
	sidekiq_options unique: true

  def perform(id)
    AftershipTracking.find(id).exec_add_to_aftership
  end
end