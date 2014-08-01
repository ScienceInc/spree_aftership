class AddShipmentIdToAftershipTrackings < ActiveRecord::Migration
  def change
    add_column :aftership_trackings, :shipment_id, :integer
    add_index :aftership_trackings, :shipment_id
  end
end