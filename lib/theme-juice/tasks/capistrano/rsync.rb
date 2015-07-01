# encoding: UTF-8

namespace :rsync do
  task :stage

  after :stage, :precompile do
    Dir.chdir fetch(:rsync_stage) do
      fetch(:rsync_install, []).each { |t| system t }
    end
  end

  # @see https://github.com/moll/capistrano-rsync/issues/15
  task :set_current_revision do
    run_locally do
      within fetch(:rsync_stage) do
        rev = capture :git, "rev-parse", "HEAD"
        set :current_revision, rev
      end
    end
  end
end
