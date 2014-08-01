require 'httpi'
require 'cgi'

class AftershipTracking < ActiveRecord::Base
  attr_accessible :tracking, :email, :order_number, :add_to_aftership_at

  belongs_to :shipment, class_name: "Spree::Shipment"
  has_one :order, through: :shipment

  def exec_add_to_aftership

    # Use em-http-request when available.
    if defined?(EventMachine::HttpRequest)
      HTTPI.adapter = :em_http
    end

    begin

      body = { "tracking" => {
                "tracking_number" => tracking, 
                "emails" => [email], 
                "order_id" => order_number,
                "customer_name" => "#{order.shipping_address.firstname} #{order.shipping_address.lastname}",
                "custom_fields" => {
                  "address1" => order.shipping_address.address1,
                  "address2" => order.shipping_address.respond_to?(:address2) ? (order.shipping_address.address2 || "") : "",
                  "city" => order.shipping_address.city,
                  "zipcode" => order.shipping_address.zipcode,
                  "state" => order.shipping_address.state.abbr,
                  "items_with_count" => shipment.line_items.collect{|li| "#{li.variant.name} (#{li.quantity})" }.join(", ") }
                }
              }

      request = HTTPI::Request.new("https://api.aftership.com/v3/trackings")
      request.headers = {"aftership-api-key" => Spree::Aftership::Config[:api_key], 'Content-Type' => 'application/json'}
      request.body = body.to_json
      response = HTTPI.post(request)

      if response.code == 201
        logger.info "Tracking added to AfterShip"
        self.update_attributes(:add_to_aftership_at => Time.now)
      else
        logger.error "Unable to add tracking number to AfterShip! Response Code: #{response.code}"
      end

    rescue Exception => e
      logger.error "AfterShip Error: #{e.message}"
      logger.error "#{e.backtrace}"
    end
  end

  def add_to_aftership
    if defined?(Delayed::Job)
      Delayed::Job.enqueue(AftershipTrackingSubmissionJob.new(self.id))
    elsif defined?(Sidekiq::Worker)
      AftershipTrackingSubmissionWorker.perform_async(self.id)
    else
      self.exec_add_to_aftership
    end
  end

  def self.add_to_aftership
    AftershipTracking.where(:add_to_aftership_at => nil).each do |tracking|
      tracking.add_to_aftership
    end
    AftershipTracking.where("add_to_aftership_at <= ?", 1.month.ago).destroy_all
  end

  private

  def post_body_from_hash(post_data)
    if post_data.is_a?(Hash)
      return post_data.map { |k, v|
        if v.instance_of?(Array)
          v.map { |e| "#{CGI.escape(k.to_s)}[]=#{CGI.escape(e.to_s)}" }.join("&")
        else
          "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
        end
      }.join("&")
    end
    nil
  end

end