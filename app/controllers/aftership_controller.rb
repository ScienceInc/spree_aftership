class AftershipController < Spree::BaseController

	def track_shipment
		respond_to do |format|
			format.html {
				redirect_to root_path
			}
			format.json {
				order = Spree::Order.where("number = ? AND email = ?", params[:order_number], params[:email])
				if order.any?
					tracked_shipments = order.first.shipments.select{|s| s.tracking.present? }
					if tracked_shipments.any?
						numbers = tracked_shipments.collect{|t| t.tracking}
						render json: {success: true, tracking_numbers: numbers}
					else
						render json: {success: true}
					end
				else
					render json: {success: false}
				end
			}
		end
	end

end