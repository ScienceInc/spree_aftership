Spree::Core::Engine.routes.draw do
  get '/track_shipment' => 'aftership#track_shipment'
end
