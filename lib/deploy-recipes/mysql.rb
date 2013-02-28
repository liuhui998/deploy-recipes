Capistrano::Configuration.instance.load do
  set_default(:mysql_host, "localhost")
  set_default(:mysql_user) { application }
  set_default(:mysql_password) { Capistrano::CLI.password_prompt "Mysql Password: " }
  set_default(:mysql_database) { "#{application}_production" }

  namespace :mysql do
    desc "Install the latest stable release of Mysql."
    task :install, roles: :db, only: {primary: true} do
      run "#{sudo} apt-get -y install libmysql-ruby libmysqlclient-dev mysql-server mysql-client"
    end
    after "deploy:install", "mysql:install"

    desc "Create a database for this application."
    task :create_database, roles: :db, only: {primary: true} do
      run %Q{mysql -uroot -p  -e "GRANT ALL PRIVILEGES   ON #{mysql_database}.*   TO '#{mysql_user}'@'localhost'  IDENTIFIED BY '#{mysql_password}'  WITH GRANT OPTION;"}
      run %Q{mysql -u#{mysql_user} -p#{mysql_password}  -e "create database #{mysql_database};"}      
    end
    after "deploy:setup", "mysql:create_database"

    desc "Generate the database.yml configuration file."
    task :setup, roles: :app do
      run "mkdir -p #{shared_path}/config"
      template "mysql.yml.erb", "#{shared_path}/config/database.yml"
    end
    after "deploy:setup", "mysql:setup"

    desc "Symlink the database.yml file into latest release"
    task :symlink, roles: :app do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
    after "deploy:finalize_update", "mysql:symlink"
  end
end
