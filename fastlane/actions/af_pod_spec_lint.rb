module Fastlane
  module Actions

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class AfPodSpecLintAction < Action
      def self.run(params)
        commands = ["pod", "spec", "lint"]
        if params[:path]
          commands << params[:path]
        end

        if params[:quick]
          commands << "--quick"
        end

        if params[:allow_warnings]
          commands << "--allow-warnings"
        end

        if params[:no_subspecs]
          commands << "--no-subspecs"
        end

        if params[:subspec]
          commands << "--subspec=#{params[:subspec]}"
        end

        result = Actions.sh("#{commands.join(" ")}")
        Helper.log.info "Successfully linted podspec".green
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Lint a pod spec"
      end

      def self.available_options
        [
                    FastlaneCore::ConfigItem.new(key: :path,
                                                 description: "The Podspec you want to lint",
                                                 optional: true,
                                                 verify_block: proc do |value|
                                                   raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                                   raise "File must be a `.podspec`".red unless value.end_with?(".podspec")
                                                 end),
                    FastlaneCore::ConfigItem.new(key: :quick,
                                                 description: "Lint skips checks that would require to download and build the spec",
                                                 optional: true,
                                                 is_string:false),
                    FastlaneCore::ConfigItem.new(key: :allow_warnings,
                                                 description: "Lint validates even if warnings are present",
                                                 optional: true,
                                                 is_string:false),
                    FastlaneCore::ConfigItem.new(key: :no_subspecs,
                                                 description: "Lint skips validation of subspecs",
                                                 optional: true,
                                                 is_string:false),
                    FastlaneCore::ConfigItem.new(key: :subspec,
                                                 description: "Lint validates only the given subspec",
                                                 optional: true,
                                                 is_string: true),
        ]
      end

      def self.output
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        ["kcharwood"]
      end

      def self.is_supported?(platform)
        platform != :android
      end
    end
  end
end
