module Fastlane
  module Actions
    module SharedValues
      GITHUB_MILESTONE_NUMBER = :GITHUB_MILESTONE_NUMBER
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class AfGetGithubMilestoneAction < Action
      def self.run(params)
        require 'net/http'
        require 'net/https'
        require 'json'
        require 'base64'

        begin
          uri = URI("https://api.github.com/repos/#{params[:owner]}/#{params[:repository]}/milestones")

          # Create client
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER

          # Create Request
          req =  Net::HTTP::Get.new(uri)
          # Add headers
          if params[:api_token]
            api_token = params[:api_token]
            req.add_field "Authorization", "Basic #{Base64.strict_encode64(api_token)}"
          end
          req.add_field "Accept", "application/vnd.github.v3+json"

          # Fetch Request
          res = http.request(req)
        rescue StandardError => e
          Helper.log.info "HTTP Request failed (#{e.message})".red
        end
        
        case res.code.to_i
          when 200
            milestones = JSON.parse(res.body)

            milestone = milestones.select {|milestone| milestone["title"] == params[:title]}.first          
          
            if milestone == nil
              raise "No milestone found matching #{params[:title]}".red
            end
          
            Helper.log.info "Milestone #{params[:title]}: #{milestone["url"]}".green
          
            if params[:verify_for_release] == true
                raise "Milestone #{params[:title]} is already closed".red unless milestone["state"] == "open"
                raise "Milestone #{params[:title]} still has open #{milestone["open_issues"]} issue(s)".red unless milestone["open_issues"] == 0
                raise "Milestone #{params[:title]} has no closed issues".red unless milestone["closed_issues"] > 0
                Helper.log.info "Milestone #{params[:title]} is ready for release!".green
            end
          
            Actions.lane_context[SharedValues::GITHUB_MILESTONE_NUMBER] = milestone["number"]
            return milestone
          when 400..499 
            json = JSON.parse(res.body)
            raise "Error Retrieving Github Milestone (#{res.code}): #{json["message"]}".red
          else
            Helper.log.info "Status Code: #{res.code} Body: #{res.body}"
            raise "Retrieving Github Milestone".red
        end
      
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get a Github Milestone, and optional verify its ready for release"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :owner,
                                       env_name: "GITHUB_OWNER",
                                       description: "The Github Owner",
                                       is_string:true,
                                       optional:false),
           FastlaneCore::ConfigItem.new(key: :repository,
                                        env_name: "GITHUB_REPOSITORY",
                                        description: "The Github Repository",
                                        is_string:true,
                                        optional:false),
           FastlaneCore::ConfigItem.new(key: :api_token,
                                        env_name: "GITHUB_API_TOKEN",
                                        description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                        is_string: true,
                                        optional: true),
           FastlaneCore::ConfigItem.new(key: :title,
                                        description: "The milestone title, typically the same as the tag",
                                        is_string: true,
                                        optional: false),   
           FastlaneCore::ConfigItem.new(key: :verify_for_release,
                                        description: "Verifies there are zero open issues, at least one closed issue, and is not closed",
                                        is_string: false,
                                        default_value:false)                                       
        ]
      end

      def self.output
        [
          ['GITHUB_MILESTONE_NUMBER', 'The milestone number']
        ]
      end

      def self.return_value
        "A Hash representing the API response"
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
