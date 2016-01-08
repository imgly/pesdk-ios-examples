module Fastlane
  module Actions
    module SharedValues
      CARTHAGE_FRAMEWORK = :CARTHAGE_FRAMEWORK
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class AfBuildCarthageFrameworksAction < Action
      def self.run(params)

        Actions.sh("carthage build --no-skip-current")
        Actions.sh("carthage archive #{params[:framework_name]}")

        path = "#{params[:framework_name]}.framework.zip"

        Actions.lane_context[SharedValues::CARTHAGE_FRAMEWORK] = path
        
        Helper.log.info "Carthage generated #{params[:framework_name]}.framework"
        
        return path
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Create a Carthage Framework for your project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :framework_name,
                                       env_name: "CARTHAGE_FRAMEWORK_NAME", # The name of the environment variable
                                       description: "The name of the framework for Carthage to generate", # a short description of this parameter
                                       is_string:true)
        ]
      end

      def self.output
        [
          ['CARTHAGE_FRAMEWORK', 'The path to the generate Carthage framework']
        ]
      end

      def self.return_value
        "The path to the zipped framework"
      end

      def self.authors
        ["kcharwood"]
      end

      def self.is_supported?(platform)
        return true
      end
    end
  end
end
