Spree::Shipment.class_eval do
  has_many :aftership_trackings

  after_save :send_tracking_to_aftership

  private

  def send_tracking_to_aftership
    if tracking && tracking_changed?

      aftership_tracking = aftership_trackings.create(:tracking => tracking, :email => order.email, :order_number => order.number)
      
      line_items.select{|li| li.tracking.present? && li.aftership_tracking_id.nil?}.each do |line_item|
        line_item.update_column(:aftership_tracking_id, aftership_tracking.id)
      end

      aftership_tracking.add_to_aftership

      unless defined?(Delayed::Job) || defined?(Sidekiq::Worker)
        # If delayed job is not present, have to manually to push all the trackings
        AftershipTracking.add_to_aftership
      end
    end
  end

end