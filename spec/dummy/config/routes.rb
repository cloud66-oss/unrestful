Rails.application.routes.draw do
  mount Unrestful::Engine => "/api/admin/v2"
end
