Capistrano::Configuration.instance.load do
  namespace :deploy do
    namespace :db do

      desc "Backup the database"
      task :backup do
        puts "Backing up database with Capistrano"
      end

    end
  end
end
