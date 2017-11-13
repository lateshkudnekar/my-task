class Product
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :description, Text
  property :pdf, Text
  has n, :images
  has n, :applications, :through => Resource
  belongs_to :category

  def handle_upload(file, id)
    path = File.join(Dir.pwd, "/public/pdf/#{id}-" + file[:filename].downcase.gsub(" ", "-"))
    if !File.exists?(path)
      File.open(path, "wb") do |f|
        f.write(file[:tempfile].read)
      end
    end
  end
end

class Category
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :priority, Integer, :default => 0
  has n, :products
end

class Image
  include DataMapper::Resource
  property :id, Serial
  property :image, String, :length => 255
  property :priority, Integer, :default => 0
  belongs_to :product
  def handle_upload(file, id)
    path = File.join(Dir.pwd, "/public/images/product/#{id}-" + file[:filename].downcase.gsub(" ", "-"))
    if !File.exists?(path)
      File.open(path, "wb") do |f|
        f.write(file[:tempfile].read)
      end
    end
  end

  def generate_thumb(file, id)
    path = File.join(Dir.pwd, "/public/images/product/#{id}-" + file[:filename].downcase.gsub(" ", "-"))
    filename = File.basename(path,File.extname(path))
    thumbpath = File.join(Dir.pwd, "/public/images/product/thumbs/" + filename + ".jpg")

    if !File.exists?(thumbpath)
      image = MiniMagick::Image.open(path)
      image.resize "300x300"
      image.format "jpg"
      image.colorspace "sRGB"
      image.write thumbpath
    end
  end
end

class Application
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :body, Text
  property :additional_detail, Text
  property :image, String
  has n, :products, :through => Resource
  def handle_upload(file, id)
    path = File.join(Dir.pwd, "/public/images/#{id}-" + file[:filename].downcase.gsub(" ", "-"))
    if !File.exists?(path)
      File.open(path, "wb") do |f|
        f.write(file[:tempfile].read)
      end
    end
  end

  def generate_thumb(file, id)
    path = File.join(Dir.pwd, "/public/images/#{id}-" + file[:filename].downcase.gsub(" ", "-"))
    filename = File.basename(path,File.extname(path))
    thumbpath = File.join(Dir.pwd, "/public/images/" + filename + ".jpg")

    if !File.exists?(thumbpath)
      image = MiniMagick::Image.open(path)
      image.resize "300x300"
      image.format "jpg"
      image.colorspace "sRGB"
      image.write thumbpath
    end
  end
end

class Cms
  include DataMapper::Resource
  property :id, Serial
  property :application_intro, Text
  property :product_intro, Text
  property :stanhex_intro, Text
end
DataMapper.finalize
