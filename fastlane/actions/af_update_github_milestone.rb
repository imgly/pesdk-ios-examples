module Fastlane
  module Actions
    module SharedValues
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class AfUpdateGithubMilestoneAction < Action
      def self.run(params)

        require 'net/http'
        require 'net/https'
        require 'json'
        require 'base64'

        begin
          uri = URI("https://api.github.com/repos/#{params[:owner]}/#{params[:repository]}/milestones/#{params[:number]}")

          # Create client
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          
          dict = Hash.new
          dict["title"] = params[:title] if params[:title] 
          dict["state"] = params[:state] if params[:state]
          dict["description"] = params[:description] if params[:description]
          dict["due_on"] = params[:due_on] if params[:due_on]
          body = JSON.dump(dict)

          # Create Request
          req =  Net::HTTP::Patch.new(uri)
          req.add_field "Content-Type", "application/json"
          api_token = params[:api_token]
          req.add_field "Authorization", "Basic #{Base64.strict_encode64(api_token)}"
          req.add_field "Accept", "application/vnd.github.v3+json"
          req.add_field "Content-Type", "application/json"
          req.body = body

          # Fetch Request
          res = http.request(req)
        rescue StandardError => e
          Helper.log.info "HTTP Request failed (#{e.message})".red
        end
        
        case res.code.to_i
          when 200
          json = JSON.parse(res.body)
          Helper.log.info "Github Release updated".green
          
          Actions.lane_context[SharedValues::GITHUB_RELEASE_ID] = json["id"]
          Actions.lane_context[SharedValues::GITHUB_RELEASE_HTML_URL] = json["html_url"]
          Actions.lane_context[SharedValues::GITHUB_RELEASE_UPLOAD_URL_TEMPLATE] = json["upload_url"]
          return json
          when 400..499 
          json = JSON.parse(res.body)
          raise "Error Creating Github Release (#{res.code}): #{json["message"]}".red
          else
          Helper.log.info "Status Code: #{res.code} Body: #{res.body}"
          raise "Error Creating Github Release".red
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Edit a Github Milestone"
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
          FastlaneCore::ConfigItem.new(key: :number,
                                       env_name: "GITHUB_MILESTONE_NUMBER",
                                       description: "The Github Release ID",
                                       is_string:true,
                                       default_value:Actions.lane_context[SharedValues::GITHUB_MILESTONE_NUMBER]),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "GITHUB_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :title,
                                       env_name: "GITHUB_MILESTONE_TITLE",
                                       description: "The title to update",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :state,
                                       env_name: "GITHUB_MILESTONE_STATE",
                                       description: "The state to update. Can be `open` or `closed`",
                                       is_string: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "`state` can only be `open` or `closed".red unless value == "open" || value == "closed"
                                       end),
          FastlaneCore::ConfigItem.new(key: :description,
                                       env_name: "GITHUB_MILESTONE_DESCRIPTION",
                                       description: "The description of the milestone",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :due_on,
                                       env_name: "GITHUB_MIELSTONE_DUE_DATE",
                                       description: "The milestone due date. This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ",
                                       is_string: true,
                                       optional: true),                                     
                                       
        ]
      end

      def self.return_value
        "The Hash representing the API response"
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
