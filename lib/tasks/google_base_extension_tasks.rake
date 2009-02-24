namespace :db do
  desc "Bootstrap your database for Spree."
  task :bootstrap  => :environment do
    # load initial database fixtures (in db/sample/*.yml) into the current environment's database
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    Dir.glob(File.join(GoogleBaseExtension.root, "db", 'sample', '*.{yml,csv}')).each do |fixture_file|
      Fixtures.create_fixtures("#{GoogleBaseExtension.root}/db/sample", File.basename(fixture_file, '.*'))
    end
  end
end

namespace :spree do
  namespace :extensions do
    namespace :google_base do
      desc "Copies public assets of the Google Base to the instance public/ directory."
      task :update => :environment do
        is_svn_git_or_dir = proc {|path| path =~ /\.svn/ || path =~ /\.git/ || File.directory?(path) }
        Dir[GoogleBaseExtension.root + "/public/**/*"].reject(&is_svn_git_or_dir).each do |file|
          path = file.sub(GoogleBaseExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end
      task :generate => :environment do
        results = _build_xml
        puts results
      end
    end
  end
end

def _build_xml
  returning '' do |output|
    xml = Builder::XmlMarkup.new(:target => output, :indent => 2)
    xml.instruct! :xml, :version => "1.0", :encoding => "UTF-9"
    xml.urlset( :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" ) {
      Product.find(:all).each do |product|
        xml.item {
          xml.id product.sku.to_s
          xml.link ''+product.permalink #add root
          xml.title product.name
          xml.description product.description
          xml.price product.master_price
          xml.condition 'New'
          #Recommended
          #xml.brand 'brand'
          #xml.image_link 'image_link'
          #xml.isbn 'isbn'
          #xml.mpn 'mpn'
          #xml.upc 'upc'
          #xml.weight 'weight'
          #Optional
          #xml.color 'color'
          #xml.expiration_date 'expiration_date'
          #xml.height 'height'
          #xml.length 'length'
          #xml.model_number 'model_number'
          #xml.payment_accepted 'payment_accepted'
          #xml.payment_notes 'payment_notes'
          #xml.price_type 'price_type'
          #xml.product_type 'product_type' #map to category
          #xml.quantity 'quantity'
          #xml.shipping 'shipping'
          #xml.size 'size'
          #xml.tax 'tax'
        }
      end
    }
  end
end