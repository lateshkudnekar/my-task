helpers do
	include Recaptcha::ClientHelper
	include Recaptcha::Verify

	def redirect_to_original_request
    user = session[:user]
    flash[:notice] = "Welcome back #{user.name}."
    original_request = session[:original_request]
    session[:original_request] = nil
    redirect original_request
  end

	def active_page?(path='')
	  request.path_info == '/' + path
	end

	def body_class(class_array=[])
		body_class = []
		body_class << class_array
		body_class.join(" ")
	end

	def page_title(title="")
		if title.nil?
			"STANHEX"
		else
			"STANHEX | #{title}"
		end
	end
end
