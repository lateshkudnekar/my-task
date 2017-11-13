get '/migrate' do
authenticate!
DataMapper.auto_migrate!
erb "Success"
end

get '/_update_db_cms' do
  authenticate!
  #CMS Intro data
  Cms.auto_migrate!
  Cms.create(:id => 1, :application_intro => "STANHEX provides customised cooling solutions for a number of fast-growing industries. Our clients prefer us for our consistent focus on quality and seamless product-integration.", :product_intro => "Our cooling solutions range from catalogue products to fully customised cooling systems. You can select the product/s you are interested in and directly send us an inquiry.", :stanhex_intro => "
  STANHEX, the industrial product line of Standard Radiators Pvt. Ltd., offers customised cooling solutions that integrate robust aluminium bar & plate technologies and other system peripherals to cater to performance-critical industries such as Renewable Energy, Locomotive, Hydraulics and Pneumatics amongst many others. And over the last decade, with specialised teams to cater to increasing demand, it has truly become a formidable brand to reckon with.

  At STANHEX, we go the extra mile to support the cooling needs of our clients by partnering with them from project inception to serial production. Since cooling needs are unique, a 'one size fits all' solution does not work. That's why we strive to offer industry-leading customization and flexibility with quick turn-around times.")
  redirect "/"
end

get '/reset' do
  authenticate!
  DataMapper.auto_migrate!
  adapter = DataMapper.repository(:default).adapter

  #CMS Intro data
  DataMapper.auto_upgrade!
  Cms.create(:id => 1, :application_intro => "STANHEX provides customised cooling solutions for a number of fast-growing industries. Our clients prefer us for our consistent focus on quality and seamless product-integration.", :product_intro => "Our cooling solutions range from catalogue products to fully customised cooling systems. You can select the product/s you are interested in and directly send us an inquiry.", :stanhex_intro => "
  STANHEX, the industrial product line of Standard Radiators Pvt. Ltd., offers customised cooling solutions that integrate robust aluminium bar & plate technologies and other system peripherals to cater to performance-critical industries such as Renewable Energy, Locomotive, Hydraulics and Pneumatics amongst many others. And over the last decade, with specialised teams to cater to increasing demand, it has truly become a formidable brand to reckon with.")


  #Category data
  e = Category.create(:id => 1, :title => "Engine Cooling", :priority => 1)
  a = Category.create(:id => 2, :title => "Charged Air Cooling", :priority => 2)
  h = Category.create(:id => 3, :title => "Hydraulic Oil Cooling", :priority => 3)
  t = Category.create(:id => 4, :title => "Transmission Oil Cooling", :priority => 4)
  f = Category.create(:id => 5, :title => "Fuel Cooling", :priority => 5)
  adapter.execute('ALTER SEQUENCE categories_id_seq RESTART WITH 6') if Sinatra::Base.production?

  #Application data

  Application.create(:id => 1, :title => "Agriculture", :body => "If you're looking for Pinterest-like presentation of thumbnails of varying heights and/or widths, you'll need to use a third-party plugin.",  :additional_detail =>'Same image to be used as in the homepage, if needed. Same intro. 3 features/Advantages. Products related to application section. We can either have the Standalone page with a long scroll, or load one at a time, and have the application grid on the homepage to navigate to the other applications.', :image => "locomotive.jpg")
  Application.create(:id => 2, :title => "Earth-Moving Construction", :body => "This is done via declarations inside your model class. The class name of the related model is determined by the symbol you pass in. For illustration, we'll add an association of each type. Pay attention to the pluralization or the related model's name.", :additional_detail =>'Same image to be used as in the homepage, if needed. Same intro. 3 features/Advantages. Products related to application section. We can either have the Standalone page with a long scroll, or load one at a time, and have the application grid on the homepage to navigate to the other applications.', :image => "locomotive.jpg")
  Application.create(:id => 3, :title => "On-highway", :body => "This is done via declarations inside your model class. The class name of the related model is determined by the symbol you pass in. For illustration, we'll add an association of each type. Pay attention to the pluralization or the related model's name.", :additional_detail =>'Same image to be used as in the homepage, if needed. Same intro. 3 features/Advantages. Products related to application section. We can either have the Standalone page with a long scroll, or load one at a time, and have the application grid on the homepage to navigate to the other applications.', :image => "locomotive.jpg")
  Application.create(:id => 4, :title => "Locomotive", :body => "This is done via declarations inside your model class. The class name of the related model is determined by the symbol you pass in. For illustration, we'll add an association of each type. Pay attention to the pluralization or the related model's name.", :additional_detail =>'Same image to be used as in the homepage, if needed. Same intro. 3 features/Advantages. Products related to application section. We can either have the Standalone page with a long scroll, or load one at a time, and have the application grid on the homepage to navigate to the other applications.', :image => "locomotive.jpg")
  Application.create(:id => 5, :title => "Power Generation", :body => "This is done via declarations inside your model class. The class name of the related model is determined by the symbol you pass in. For illustration, we'll add an association of each type. Pay attention to the pluralization or the related model's name.", :additional_detail =>'Same image to be used as in the homepage, if needed. Same intro. 3 features/Advantages. Products related to application section. We can either have the Standalone page with a long scroll, or load one at a time, and have the application grid on the homepage to navigate to the other applications.', :image => "locomotive.jpg")
  adapter.execute('ALTER SEQUENCE applications_id_seq RESTART WITH 6') if Sinatra::Base.production?

  #Products data
  p1 = e.products.create(:id => 1, :title => "Plastic Tank Radiators", :description => "Pages you view in incognito tabs won’t stick around in your browser’s history, cookie store, or search history after you’ve closed all of your incognito tabs. Any files you download or bookmarks you create will be kept. This will edit the description.")
  p2 = a.products.create(:id => 2, :title => "Intercoolers")
  p3 = h.products.create(:id => 3, :title => "Hydraulic Oil Cooler")
  p4 = t.products.create(:id => 4, :title => "Transmission Oil Cooler")
  p5 = f.products.create(:id => 5, :title => "Fuel Coolers")
  p6 = e.products.create(:id => 6, :title => "Al Radiators")
  adapter.execute('ALTER SEQUENCE products_id_seq RESTART WITH 7') if Sinatra::Base.production?

  #Images data
  p1.images.create(:id => 1, :image => "1-radiator_new.jpg", :priority => 1)
  p2.images.create(:id => 2, :image => "2-radiator.jpg", :priority => 1)
  p3.images.create(:id => 3, :image => "3-01-classic-radiator.jpg", :priority => 1)
  p4.images.create(:id => 4, :image => "4-crossroom_radiator_01.jpg", :priority => 1)
  p5.images.create(:id => 5, :image => "5-aluminum-vertical-radiator.jpg", :priority => 1)
  p6.images.create(:id => 6, :image => "6-mercedes-truck-radiator-250x250.jpg", :priority => 1)
  adapter.execute('ALTER SEQUENCE images_id_seq RESTART WITH 7') if Sinatra::Base.production?
  redirect "/"
end
