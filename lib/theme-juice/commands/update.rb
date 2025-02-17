# encoding: UTF-8

module ThemeJuice
  module Commands
    class Update < Command

      def initialize(opts = {})
        super

        runner do |tasks|
          tasks << Tasks::VMUpdateBox.new
        end
      end
    end
  end
end
