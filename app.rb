require 'rubygems'
require "rdiscount"
require 'sinatra/partial'
require 'sinatra'
require 'data_mapper'
require 'dotenv'
require 'sinatra/flash'
require 'sinatra/support'
require 'mini_magick'
require 'sinatra/form_helpers'
require 'sinatra/reloader'
require 'recaptcha'
require 'yaml'
require_relative 'lib/core_ext/object'
require_relative 'lib/authentication.rb'
require_relative 'lib/user.rb'

enable :sessions
set :session_secret, "WhzON"
if File.exist?(".env")
  Dotenv.load(".env")
end

TEN_MINUTES ||= 60 * 10
use Rack::Session::Pool, expire_after: TEN_MINUTES # Expire sessions after ten minutes of inactivity
use Rack::MethodOverride
helpers Authentication

Recaptcha.configure do |config|
  @creds = YAML.load_file('credentials.yml')
  config.public_key = @creds['recaptcha']['public']
  config.private_key = @creds['recaptcha']['secret']
  # config.api_version = 'v2'
end

configure :development do
	require 'dm-sqlite-adapter'
	DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db.db")
end

configure :test do
	require 'dm-sqlite-adapter'
	DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/test.db")
end

configure :production do
	require 'dm-postgres-adapter'
	DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

load 'models.rb'
load 'migration.rb'
load 'helpers.rb'
load 'mail_sender.rb'

before do
	@admin = session[:user]
	headers 'Content-Type' => 'text/html; charset=utf-8'
end

class Main < Sinatra::Base
	register Sinatra::Reloader
  helpers Sinatra::FormHelpers
	register Sinatra::Partial
end
set :partial_template_engine, :erb

get '/signin/?' do
  erb :signin, locals: { title: 'Sign In' }
end

post '/signin/?' do
  if user = User.authenticate(params)
    session[:user] = user
    redirect_to_original_request
  else
    flash[:notice] = 'You could not be signed in. Did you enter the correct username and password?'
    redirect '/signin'
  end
end

get '/signout' do
  session[:user] = nil
  flash[:notice] = 'You have been signed out.'
  redirect '/'
end


get '/' do
  @title = "Home"
  @categories = Category.all
  @active_category = Category.first(:title => 'Engine Cooling').id
  @products = Product.all(:category => { :id => @active_category })
  @applications = Application.all
  @cms = Cms.first
  erb :index
end

get '/about' do
	@title = "About us"
  erb :about
end

get '/contact' do
	@title = "Contact"
  erb :contact
end

get '/products' do
	if params[:filter]
		if params[:id] !='all'
			@products = Product.all(:category => { :id => params[:id] })
		else
			@products = Product.all
		end
		if !@products.blank?
			partial(:"partials/_products_block", :layout => false, :locals => { :products => @products })
		end
	else
		redirect '/'
	end
end

get '/products/:id/edit' do
	# authenticate!
	@applications = Application.all
	@categories = Category.all
	@product = Product.get(params[:id])
	if !@product.nil?
    if !@product.images.empty?
      @product.images = @product.images.sort_by { |h| h[:priority] }.reverse!
    end
		@title = "Edit #{@product.title}"
		erb :'admin/product/edit', :layout => :admin_layout
	else
		redirect :'products'
	end
end

get '/products/:id/download' do
	product = Product.get(params[:id])
	send_file File.join(Dir.pwd, "/public/pdf/#{product.pdf}"), :filename => product.pdf, :type => 'Application/pdf'
	redirect :'product'
end

get '/products/new/?' do
	# authenticate!
	@applications = Application.all
	@categories = Category.all
	@product = Product.new
	@title = "New Product"
	erb :'admin/product/new', :layout => :admin_layout
end

get '/products/:id' do
	@product = Product.get(params[:id])
	@products = Product.all(:id.not => params[:id])

	if !@product.nil?
    if !@product.images.nil?
      @product.images = @product.images.sort_by { |h| h[:priority] }.reverse!
    end
		erb :'product'
	else
		redirect :'products'
	end
end

post '/products' do
	# authenticate!
	priorityPending = true
	category = Category.get(params[:category_id])
	product = category.products.new(params[:product])
	if !params[:applications].nil?
		params[:applications].each do |id|
			application = Application.get(id)
			product.applications << application
		end
	end
	if product.save!
		if !params[:pdf].nil?
			pdf = params[:pdf][:filename].downcase.gsub(" ", "-") unless params[:pdf].nil?
			product.update({ :pdf => "#{product.id}-" + pdf })
			product.handle_upload(params[:pdf], product.id)
		end

		if !params[:photo].nil?
			params[:photo].each do |f|
				priorityValue = 0
				if (f[:filename] == params[:priority]) && (priorityPending)
					priorityPending = false
					priorityValue = 1
				end
			photo_file = f[:filename].downcase.gsub(" ", "-")
			images = product.images.create({ :image => "#{product.id}-" + photo_file, :priority => priorityValue	})
			images.handle_upload(f, product.id)
			images.generate_thumb(f, product.id)
			end
		end
		redirect :/
	else
		erb :'/products/new', :layout => :admin_layout
	end
end

put '/products' do
	# authenticate!
  priorityPending = true
	product = Product.get(params[:id])
	applications = ApplicationProduct.all(:product_id => params[:id])

  if !applications.nil?
    applications.destroy
  end

  if !params[:applications].nil?
		params[:applications].each do |newApp|
			application = Application.get(newApp)
			product.applications << application
		end
  end
    if !params[:pdf].nil?
      pdf = params[:pdf][:filename].downcase.gsub(" ", "-") unless params[:pdf].nil?
      product.update({ :pdf => "#{product.id}-" + pdf })
      product.handle_upload(params[:pdf], product.id)
    end

	if product.update(params[:product])
		product.update({:category_id => params[:category_id]})
		if !params[:photo].nil?
			params[:photo].each do |f|
        priorityValue = 0
				if (f[:filename] == params[:priority]) && (priorityPending)
          if !product.images.empty?
            product.images = product.images.sort_by { |h| h[:priority] }.reverse!
            priorityValue = product.images[0].priority + 1;
          else
            priorityValue = 1
          end
					priorityPending = false
				end
  			photo_file = f[:filename].downcase.gsub(" ", "-")
  			images = product.images.create({ :image => "#{product.id}-" + photo_file, :priority => priorityValue	})
  			images.handle_upload(f, product.id)
  			images.generate_thumb(f, product.id)
			end
		end
		redirect :"/"
	else
		redirect :"/product/#{product.id}/edit"
	end

end

delete '/products' do
	# authenticate!
	product = Product.get(params[:id])
    if !product.images.empty?
      product.images.each do |image|
        file = Dir.pwd+"/public/images/product/" + image.image
        thumb_file = Dir.pwd+"/public/images/product/thumbs/" + image.image

        if image.destroy
          File.delete(thumb_file) if File.exist? (thumb_file)
          File.delete(file) if File.exist? (file)
        end
      end
    end

    if !product.application_products.empty?
      product.application_products.all.destroy
    end

  if Product.get(params[:id]).destroy
		puts :products
	else
		puts :"products/#{product.id}/edit", :layout => :admin_layout
	end
end

post '/contact' do
  if verify_recaptcha
    require 'pony'
    @name = params[:name]
    @email = params[:email]
    @phone = params[:phone] unless params[:phone].nil?
    @message = params[:message] unless params[:message].nil?
    @products = params[:selected_products] unless params[:selected_products].nil?

    contacts = ['sales@stanhex.com']

    MailSender.new('credentials.yml',
                     contacts,
                     'STANHEX: Contact form enquiry',
                     erb(:mailer_contact, :layout => false)).handle
    "Message is sent. Thank you!"
  else
    "Captcha Verification Failed"
  end
end

# get '/applications' do
# 		@title = "Applications"
# 		@applications = Application.all()
#     @cms = Cms.first
#     erb :applications
# end

get '/applications/:id/edit' do
	authenticate!
	@application = Application.get(params[:id])
	erb :"admin/application/edit", :layout => :admin_layout
end

get '/applications/new' do
	authenticate!
	@application = Application.new
	@title = "New Application"
	erb :'admin/application/new', :layout => :admin_layout
end

post '/applications/' do
	authenticate!
	application = Application.new(params[:application])
	if application.save
		if !params[:photo].nil?
			photo_file = params[:photo][:filename].downcase.gsub(" ", "-")
			application.handle_upload(params[:photo], application.id)
			application.generate_thumb(params[:photo], application.id)
			application.update({:image => "#{application.id}-" + photo_file
										 })
		end
		redirect :"/"
	else
		erb :'admin/application/new', :layout => :admin_layout
	end
end

put '/applications/:id' do
	authenticate!
	application = Application.get(params[:id])
	if application.update(params[:application])
		if !params[:photo].nil?
			photo_file = params[:photo][:filename].downcase.gsub(" ", "-")
			application.handle_upload(params[:photo], application.id)
			application.generate_thumb(params[:photo], application.id)
			application.update({:image => "#{application.id}-" + photo_file
										 })
		end
		redirect :"/applications"
	else
		erb :"admin/application/#{application.id}/edit"
	end
end

delete '/applications/:id' do
	authenticate!
	application = Application.get(params[:id])
	file = Dir.pwd+"/public/images/" + application.image

  if !application.application_products.empty?
    application.application_products.all.destroy
  end

	if Application.get(params[:id]).destroy
		File.delete(file)  if File.exist? (file)
		redirect :applications
	end
end

delete '/images' do
	imageObj = Image.get(params[:image])
  file = Dir.pwd+"/public/images/product/" + imageObj.image
  thumb_file = Dir.pwd+"/public/images/product/thumbs/" + imageObj.image

	if imageObj.destroy
    File.delete(file) if File.exist? (file)
    File.delete(thumb_file) if File.exist? (thumb_file)
  end
end

put '/images' do
  imageObj = Image.all(:product_id => params[:product], :order => [:priority.desc])
  priority = imageObj[0].priority + 1;
  imageObj.get(params[:image]).update(:priority => priority)
end

get '/categories' do
  @categories = Category.all(:order => [:priority.asc])
  erb :"categories", :layout => :admin_layout
end

post '/categories' do
  maxPriority = Category.max(:priority)
  newCategory = Category.new(:title => params[:category_title], :priority => maxPriority + 1)
  if newCategory.save
      partial(:"partials/_category_block", :layout => false, :locals=> { category: newCategory, showPriority: true })
  end
end

delete '/categories' do
  category = Category.get(params[:id])
	defaultCategory = Category.first(:id.not => params[:id])
  products = Product.all(:category_id => params[:id])
  if products
    products.each do |product|
      product.update(:category_id => defaultCategory.id) #this sould be replaced with default category
    end
  end
  category.destroy
end

put '/categories' do
	category = Category.get(params[:id])
  if params[:direction]
    priorityA = category.priority
    direction = params[:direction]
    priorityB = (direction == 'up') ? Category.last(:priority.lt => category.priority) : Category.first(:priority.gt => category.priority)

    if category.update({:priority => priorityB.priority}) && priorityB.update({:priority => priorityA})
        # category.priority.to_s
        @categories = Category.all(:order => [:priority.asc])
        erb :"partials/_categories_block", :layout => false, :locals=> { categories: @categories }
    end
  else
    if category.update({:title => params[:title]})
      category.title
    end
  end
end

get '/admin' do
  authenticate!
  @categories = Category.all
	@products = Product.all
	@applications = Application.all
  erb :'admin/index', :layout => :admin_layout
end

get '/admin/applications' do
  authenticate!
  @applications = Application.all
  erb :'admin/application/index', :layout => :admin_layout
end

get '/admin/products' do
  authenticate!
  @products = Product.all
  erb :'admin/product/index', :layout => :admin_layout
end

post '/changewelcomeimage' do
  previousImagePath = "/public/images/welcome.jpg"
  newImage = params[:image]
  newImagePath = File.join(Dir.pwd, "/public/images/welcome.jpg")
  if File.exists?(previousImagePath)
    File.destroy(patpreviousFileh)
  end
  File.open(newImagePath, "wb") do |f|
    f.write(newImage[:tempfile].read)
  end
  puts params[:image]
end

post '/changecmscontent' do
  field = params[:field]
  content = params[:content]
  Cms.update(field => content)
end

get '/:slug' do
  slugs = %w[about-us applications products contact-us]
  if slugs.include? params[:slug]
    @title = "Home"
    @categories = Category.all
    @active_category = Category.first(:title => 'Engine Cooling').id
    @products = Product.all(:category => { :id => @active_category })
    @applications = Application.all
    @cms = Cms.first
    if params[:filter]
      @products = Product.all(:category => { :id => params[:id] }) if params[:id] !='all'
      partial(:"partials/_products_block", :layout => false, :locals => { :products => @products }) if !@products.blank?
    else
      erb :index
    end
  else
    pass
  end
end
