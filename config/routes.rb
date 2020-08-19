Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    root to: 'badges#home'

    resources :badges do
  	collection do
  		post :assign_badge
  		get :total_badge
  	end
  end
end
