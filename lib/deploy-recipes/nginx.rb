Capistrano::Configuration.instance.load do
  namespace :nginx do
    desc "Install latest stable release of nginx"
    task :install, roles: :web do
      run "#{sudo} add-apt-repository ppa:nginx/stable"
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install nginx"
    end
    after "deploy:install", "nginx:install"

    desc "Setup nginx configuration for this application"
    task :setup, roles: :web do
      template "nginx_unicorn.erb", "/tmp/nginx_conf"
      run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
      run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
      
      run "mkdir -p #{shared_path}/uploads"
      restart
    end
    after "deploy:setup", "nginx:setup"

    desc "Symlink the uploads directory into latest release"
    task :symlink, roles: :app do
      run "rm -rf  #{release_path}/public/uploads"
      run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
    end
    
    after "deploy:finalize_update", "nginx:symlink"
    
    %w[start stop restart].each do |command|
      desc "#{command} nginx"
      task command, roles: :web do
        run "#{sudo} service nginx #{command}"
      end
    end
  end
end
