Rails.application.routes.draw do
 get 'reports/borrowings', to: 'reports#borrowings', defaults: {format: :xlsx}
 get 'reports/overdue', to: 'reports#overdue', defaults: {format: :xlsx}

  get 'covers/:id', to: 'files#cover', as: :cover
  get 'id_scans/:id', to: 'files#scan', as: :id_scan
  get 'attachments/:kind/:id', to: 'files#edit', as: :attachment
  patch 'attachments/:kind/:id', to: 'files#update'

  devise_for :users
  root 'pages#home'

  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'

  resources :books
  resources :authors
  resources :members
  resources :borrowings
end
