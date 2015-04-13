# encoding: UTF-8

module ThemeJuice
  class Service::Delete < ::ThemeJuice::Service

    #
    # @param {Hash} opts
    #
    def initialize(opts)
      opts = ThemeJuice::Interaction::Delete.get_project_options(opts)
      super
    end

    #
    # Remove all traces of site from Vagrant
    #
    # @return {Void}
    #
    def delete
      @interaction.speak "Are you sure you want to delete '#{@opts[:project_name]}'? (y/N)", {
        :color => [:white, :on_red],
        :icon  => :notice,
        :row   => true
      }

      if @interaction.agree? "", { :color => :red, :simple => true }

        remove_dev_site      if dev_project_is_setup?
        remove_database      if database_is_setup?
        remove_synced_folder if synced_folder_is_setup?

        if removal_was_successful?
          @interaction.success "Project '#{@opts[:project_name]}' successfully removed!"

          restart_vagrant if @opts[:restart]
        else
          @interaction.error "Project '#{@opts[:project_name]}' could not be fully be removed."
        end
      end
    end

    private

    #
    # Remove all theme files from Vagrant directory
    #
    # @return {Void}
    #
    def remove_dev_site

      unless Dir.entries("#{@environment.vvv_path}").include? "www"
        @interaction.error "Cannot load VVV path. Aborting mission before something bad happens."
      end

      if run ["rm -rf #{@opts[:project_dev_location]}"]
        @interaction.log "Development project removed"
      else
        @interaction.error "Project '#{@opts[:project_name]}' could not be removed. Make sure you have write capabilities to '#{@opts[:project_dev_location]}'."
      end
    end

    #
    # Remove database block from init-custom.sql
    #
    # @return {Void}
    #
    def remove_database
      if remove_traces_from_file "#{@environment.vvv_path}/database/init-custom.sql"
        @interaction.log "Database removed"
      end
    end

    #
    # Remove synced folder block from Vagrantfile
    #
    # @return {Void}
    #
    def remove_synced_folder
      if remove_traces_from_file "#{@environment.vvv_path}/Vagrantfile"
        @interaction.log "Synced folders removed"
      end
    end

    #
    # Remove all traces of auto-generated content from file
    #
    # @param {String} input_file
    #
    # @return {Void}
    #
    def remove_traces_from_file(input_file)
      begin
        # Create new tempfile
        output_file = Tempfile.new File.basename(input_file)
        # Copy over contents of actual file to tempfile
        open File.expand_path(input_file), "r" do |file|
          # Remove traces of theme from contents
          output_file.write "#{file.read}".gsub(/(#(#*)? Begin '#{@opts[:project_name]}')(.*?)(#(#*)? End '#{@opts[:project_name]}')\n+/m, "")
        end
        # Move temp file to actual file location
        FileUtils.mv output_file, File.expand_path(input_file)
      rescue LoadError => err
        @interaction.error "There was an error!" do
          puts err
        end
      ensure
        # Make sure that the tempfile closes and is cleaned up, regardless of errors
        output_file.close
        output_file.unlink
      end
    end
  end
end
