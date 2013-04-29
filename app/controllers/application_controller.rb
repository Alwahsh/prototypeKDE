class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  def set_locale
    cookies.permanent[:lang] = params[:lang] if params[:lang].present?
    I18n.locale = cookies[:lang] if cookies[:lang].present?
    
  end
end


