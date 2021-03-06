Capistrano::Configuration.instance.load do
  set_default :ruby_version, "2.0.0-p0"
  set_default :rbenv_bootstrap, "bootstrap-ubuntu-12-04"

  namespace :rbenv do
    desc "Install rbenv, Ruby, and the Bundler gem"
    task :install, roles: :app do
      run "#{sudo} apt-get -y install curl git-core"
      run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
      bashrc = <<-BASHRC
if [ -d $HOME/.rbenv ]; then 
  export PATH="$HOME/.rbenv/bin:$PATH" 
  eval "$(rbenv init -)" 
  fi
  BASHRC
  put bashrc, "/tmp/rbenvrc"
  run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
  run "mv ~/.bashrc.tmp ~/.bashrc"
  #sed -i 's/ftp\.ruby-lang\.org\/pub\/ruby/ruby\.taobao\.org\/mirrors\/ruby/g' 2.0.0-p0
  # rbenv install 2.0.0-p0      
  run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
  run %q{eval "$(rbenv init -)"}
  run "rbenv -v"
  run "#{sudo} apt-get -y install openssl libssl-dev  libxslt-dev sqlite3 libsqlite3-dev libmagickwand-dev  imagemagick"  
  run %q{sed "s/sudo/sudo -p 'sudo password: '/g" $HOME/.rbenv/plugins/rbenv-bootstrap/bin/rbenv-} + rbenv_bootstrap + " | bash"

  run "rbenv install #{ruby_version}"
  run "rbenv global #{ruby_version}"
  run "gem install bundler --no-ri --no-rdoc"
  run "gem install whenever --no-ri --no-rdoc"  
  run "gem install backup --no-ri --no-rdoc"    
  run "rbenv rehash"
end
after "deploy:install", "rbenv:install"
end
end
