FlashDeal::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'pins/show_random' => 'pins#show_random'
  get 'pins/mysql_find_the_latest_pins' => 'pins#mysql_find_the_latest_pins'
  get 'pins/es_find_the_latest_pins' => 'pins#es_find_the_latest_pins'
  get 'pins/mongo_find_the_latest_pins' => 'pins#mongo_find_the_latest_pins'

  get 'pins/es_random_lookup' => 'pins#es_random_lookup'
  get 'pins/mysql_random_lookup' => 'pins#mysql_random_lookup'
  get 'pins/mongo_random_lookup' => 'pins#mongo_random_lookup'

  get 'pins/mysql_get_distinct_values' => 'pins#mysql_get_distinct_values'
  get 'pins/es_get_distinct_values' => 'pins#es_get_distinct_values'
  get 'pins/mongo_get_distinct_values' => 'pins#mongo_get_distinct_values'


  get 'pins/mysql_update_a_pin' => 'pins#mysql_update_a_pin'
  get 'pins/es_update_a_pin' => 'pins#es_update_a_pin'
  get 'pins/mongo_update_a_pin' => 'pins#mongo_update_a_pin'

  get 'pins/mysql_create_a_br_pin' => 'pins#mysql_create_a_br_pin'
  get 'pins/es_create_a_br_pin' => 'pins#es_create_a_br_pin'
  get 'pins/mongo_create_a_br_pin' => 'pins#mongo_create_a_br_pin'


  get 'pins/mysql_factes_on_fields' => 'pins#mysql_factes_on_fields'
  get 'pins/es_factes_on_fields' => 'pins#es_factes_on_fields'

  get 'pins/mysql_look_up_with_attributes_in_other_tables' => 'pins#mysql_look_up_with_attributes_in_other_tables'

  get 'pins/mysql_filter_by_pinner_id_and_sort_by_social_rank' => 'pins#mysql_filter_by_pinner_id_and_sort_by_social_rank'
  get 'pins/es_filter_by_pinner_id_and_sort_by_social_rank' => 'pins#es_filter_by_pinner_id_and_sort_by_social_rank'
  get 'pins/mongo_filter_by_pinner_id_and_sort_by_social_rank' => 'pins#mongo_filter_by_pinner_id_and_sort_by_social_rank'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :deals
  resource :pins

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  namespace :mongo do
    resource :deals
  end

  namespace :mysql do
    resource :pins
  end
  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
