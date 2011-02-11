load "config/db"
load "local/config/deploy.rb" if File.exists?("local/config/deploy.rb")

set :scm, "git"
set :repository, "git://github.com/scottwillson/racing_on_rails.git"
set :site_local_repository, "git@butlerpress.com:#{application}.git"
set :site_local_repository_branch, nil
set :branch, "master"
set :deploy_via, :remote_cache
set :keep_releases, 5

set :deploy_to, "/usr/local/www/rails/#{application}"

set :user, "app"
set :use_sudo, false
set :scm_auth_cache, true

set :default_environment, { 
  'PATH'         => "/usr/local/rvm/gems/ruby-1.9.2-p136/bin:/usr/local/rvm/gems/ruby-1.9.2-p136@global/bin:/usr/local/rvm/rubies/ruby-1.9.2-p136/bin:$PATH",
  'RUBY_VERSION' => 'ruby-1.9.2-p136',
  'GEM_HOME'     => '/usr/local/rvm/gems/ruby-1.9.2-p136',
  'GEM_PATH'     => '/usr/local/rvm/gems/ruby-1.9.2-p136:/usr/local/rvm/gems/ruby-1.9.2-p136@global'
}

namespace :deploy do
  desc "Deploy association-specific customizations"
  task :local_code do
    if site_local_repository_branch
      run "git clone #{site_local_repository} -b #{site_local_repository_branch} #{release_path}/local"
    else
      run "git clone #{site_local_repository} #{release_path}/local"
    end
    run "chmod -R g+w #{release_path}/local"
    run "ln -s #{release_path}/local/public #{release_path}/public/local"
  end
  
  task :symlinks do
    run <<-CMD
      rm -rf #{latest_release}/tmp/pids &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
      rm -rf #{latest_release}/tmp/sockets &&
      ln -s #{shared_path}/sockets #{latest_release}/tmp/sockets
    CMD
  end

  task :copy_cache do
    %w{ bar bar.html events people index.html results results.html teams teams.html }.each do |cached_path|
      run("if [ -e \"#{previous_release}/public/#{cached_path}\" ]; then cp -pr #{previous_release}/public/#{cached_path} #{release_path}/public/#{cached_path}; fi") rescue nil
    end
  end
  
  task :start do
    run "/usr/local/etc/rc.d/unicorn start #{application}"
  end
  
  task :stop do
    run "/usr/local/etc/rc.d/unicorn stop #{application}"
  end
  
  task :restart do
    run "/usr/local/etc/rc.d/unicorn reload #{application}"
  end

  namespace :web do
    desc "Present a maintenance page to visitors"
    task :disable, :roles => :web, :except => { :no_release => true } do
      on_rollback { run "rm #{shared_path}/system/maintenance.html" }
      run "if [ -f #{previous_release}/public/maintenance.html ]; then cp #{previous_release}/public/maintenance.html #{shared_path}/system/maintenance.html; fi"
      run "if [ -f #{previous_release}/local/public/maintenance.html ]; then cp #{previous_release}/local/public/maintenance.html #{shared_path}/system/maintenance.html; fi"
    end
  end
end

after "deploy:update_code", "deploy:local_code", "deploy:symlinks", "deploy:copy_cache"
