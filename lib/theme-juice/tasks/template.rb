# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Template < Task

      def initialize(opts = {})
        super
      end

      def execute
        return unless @project.template

        clone_template
        render_template_config_erb if @config.exist?
        install_template
      end

      private

      def clone_template
        @io.log "Cloning template"
        @util.inside @project.location do
          @util.run [], { :verbose => @env.verbose,
            :capture => @env.quiet } do |cmds|
            cmds << "git clone --depth 1 #{@project.template} ."
            if @project.template_revision
              cmds << "git checkout #{@project.template_revision}"
            end
          end
        end
      end

      def render_template_config_erb
        @io.log "Rendering template config ERB"
        save_template_config ERB.new(File.read(@config.path)).result(
          @project.to_h.merge(@env.to_h).to_ostruct.instance_eval { binding }
        )
      end

      def save_template_config(contents)
        @io.log "Saving rendered template config"
        File.open(@config.path, "w+") { |f| f << contents }
        @config.refresh!
      end

      def install_template
        @io.log "Running template installation"
        @config.command :install
      end
    end
  end
end
