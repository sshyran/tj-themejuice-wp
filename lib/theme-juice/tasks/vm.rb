# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VM < Task

      def initialize(opts = {})
        super
      end

      def execute
        @interact.log "Setting up VM"

        install_vvv unless vvv_is_installed?
      end

      def unexecute
      end

      private

      def vvv_is_installed?
        File.exist? @env.vm_path
      end

      def install_vvv
        @interact.log "Installing VVV"

        @util.run "git clone --branch '1.2.0' https://github.com/Varying-Vagrant-Vagrants/VVV.git #{@env.vm_path}", :verbose => @env.verbose
      end
    end
  end
end
