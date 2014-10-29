class AftershipController < Spree::BaseController

	def track_shipment
		respond_to do |format|
			format.html {
				redirect_to root_path
			}
			format.json {
				# for testing purposes enter order number and email as 'test'
				if params[:order_number].match(/^test/) && params[:email] = "test"
					numbers = []
					num = params[:order_number][-1].to_i
					if num > 0
						num.times do |i|
							numbers << "testtracking#{i+1}"
						end
						render json: {success: true, tracking_numbers: numbers, shipped_at: DateTime.now.to_date} and return
					else
						render json: {success: true} and return
					end
				else
					order = Spree::Order.where("number = ? AND email = ?", params[:order_number], params[:email])
				end

				if order.any?
					tracked_shipments = order.first.shipments.select{|s| s.tracking.present? }
					if tracked_shipments.any?
						numbers = tracked_shipments.collect{|t| t.tracking}
						render json: {success: true, tracking_numbers: numbers, shipped_at: tracked_shipments.last.shipped_at.to_date}
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