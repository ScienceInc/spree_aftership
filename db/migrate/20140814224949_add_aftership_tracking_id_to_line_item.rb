class AddAftershipTrackingIdToLineItem < ActiveRecord::Migration
  def change
  	add_column :spree_line_items, :aftership_tracking_id, :integer
  	add_index :spree_line_items, :aftership_tracking_id
  end
end