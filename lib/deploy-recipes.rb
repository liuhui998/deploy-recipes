require "deploy-recipes/version"

puts "#########################################"
puts "deploy-recipes/version"
puts "#{File.dirname(__FILE__)}/deploy-recipes/recipes"

Dir.glob("#{File.dirname(__FILE__)}/deploy-recipes/recipes/*.rb").each { |t|
  puts t.inspect
  require t 
}

Dir.glob("#{File.dirname(__FILE__)}/deploy-recipes/recipes/*.rake").each { |t| import t }


module Deploy
  module Recipes
    # Your code goes here...
  end
end
