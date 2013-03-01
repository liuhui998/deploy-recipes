Capistrano::Configuration.instance.load do
  set_default(:mysql_host, "localhost")
  set_default(:mysql_user) { application }
  set_default(:mysql_password) { Capistrano::CLI.password_prompt "Mysql Password: " }
  set_default(:mysql_root_password) { Capistrano::CLI.password_prompt "Mysql Root Password: " }  
  set_default(:mysql_database) { "#{application}_production" }

  namespace :mysql do
    desc "Install the latest stable release of Mysql."
    task :install, roles: :db, only: {primary: true} do
      run "#{sudo} apt-get -y install libmysql-ruby libmysqlclient-dev  mysql-client"

      run "#{sudo} apt-get -y install mysql-server" do |channel, stream, data|
        # prompts for mysql root password (when blue screen appears)
        channel.send_data("#{mysql_root_password}\n\r") if data =~ /password/
      end      
      template "my.conf.sed", "/tmp/my.conf.sed"
      run "sed -f /tmp/my.conf.sed /etc/mysql/my.cnf > /tmp/tmp.my.conf"
      run "#{sudo}  mv  /tmp/tmp.my.conf  /etc/mysql/my.cnf"      
      run "#{sudo}  service mysql restart"      
    end
    after "deploy:install", "mysql:install"

    desc "Create a database for this application."
    task :create_database, roles: :db, only: {primary: true} do
      run %Q{mysql -uroot -p#{mysql_root_password}  -e "GRANT ALL PRIVILEGES   ON #{mysql_database}.*   TO '#{mysql_user}'@'localhost'  IDENTIFIED BY '#{mysql_password}'  WITH GRANT OPTION;"}
      run %Q{mysql -u#{mysql_user} -p#{mysql_password}  -e "create database IF NOT EXISTS #{mysql_database};"}      
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
