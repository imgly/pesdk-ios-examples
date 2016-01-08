module Fastlane
  module Actions
    class AfPushGitTagsToRemoteAction < Action
      def self.run(params)
          commands = ["git", "push"]
            
          if params[:remote]
            commands << "#{params[:remote]}"
          end

          commands << "--tags"

          result = Actions.sh("#{commands.join(" ")}")
          Helper.log.info "Tags pushed to remote".green
          return result
        end

        #####################################################
        # @!group Documentation
        #####################################################

        def self.description
          "Push local tags to the remote - this will only push tags"
        end

        def self.available_options
          [
          FastlaneCore::ConfigItem.new(key: :remote,
                                       env_name: "FL_PUSH_GIT_TAGS_REMOTE",
                                       description: "The remote to push tags too",
                                       is_string:true,
                                       optional:true)
          ]
        end

        def self.author
          ['vittoriom']
        end

        def self.is_supported?(platform)
          true
        end
      end
    end
  end

        