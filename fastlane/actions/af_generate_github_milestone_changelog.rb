module Fastlane
  module Actions
    module SharedValues
       GITHUB_MILESTONE_CHANGELOG = :GITHUB_MILESTONE_CHANGELOG
    end

    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class AfGenerateGithubMilestoneChangelogAction < Action
      def self.english_join(array = nil)
        return "" if array.nil? or array.length == 0
        return array[0] if array.length == 1
        array[0..-2].join(", ") + " and " + array[-1]
      end
      
      def self.markdown_for_changelog_section (github_owner, github_repository, api_token, section, issues)
        changelog = "\n#### #{section}\n"
        issues.each do |issue|
          authors = getAuthorsForIssue(github_owner,github_repository, api_token, issue)
          
          changelog << "* #{issue["title"]}\n"
          changelog << " * Implemented by #{english_join(authors)} in [##{issue["number"]}](#{issue["html_url"]}).\n"
        end
        return changelog
      end
      
      def self.getResponseForURL(url, api_token)
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        # Create Request
        req =  Net::HTTP::Get.new(uri)
        req.add_field "Authorization", "Basic #{Base64.strict_encode64(api_token)}" if api_token != nil
        req.add_field "Accept", "application/vnd.github.v3+json"
        begin
          httpResponse = http.request(req)
          begin
            case httpResponse.code.to_i
              when 200..299
                response = JSON.parse(httpResponse.body)
              when 400..499 
                response = JSON.parse(httpResponse.body)
                raise "Error (#{response.code}): #{response["message"]}".red
              else
                Helper.log.info "Status Code: #{httpResponse.code} Body: #{httpResponse.body}"
                raise "Error with request".red
            end
            
          rescue

          end
        rescue => ex
          raise "Error fetching remote file: #{ex}".red
        end
        return response
      end
      
      def self.getIssuesForMilestone (github_owner, github_repository, api_token, milestone)
        url = "https://api.github.com/search/issues?q=repo:#{github_owner}/#{github_repository}+milestone:#{milestone}+state:closed"
        
        response = getResponseForURL(url, api_token)
        return response["items"]
      end
      
      def self.getAuthorsForIssue(github_owner, github_repository, api_token, issue)
        if issue.has_key?("pull_request")
          url = "https://api.github.com/repos/#{github_owner}/#{github_repository}/pulls/#{issue["number"]}/commits"

         commits = getResponseForURL(url, api_token)
         
         authors = Array.new
         commits.each do |commit|
           author = commit["commit"]["author"]
           if authors.include?(author["name"]) == false
             authors << author["name"]
           end
         end
         return authors
        else
          return [issue["user"]["login"]]
        end
      end
      
      
      def self.run(params)
        require 'net/http'
        require 'fileutils'
        
        issues = getIssuesForMilestone(params[:github_owner], params[:github_repository], params[:api_token], params[:milestone])
        
        if issues.count == 0 && params[:allow_empty_changelog] == false
          raise "No closed issues found for #{params[:milestone]} in #{params[:github_owner]}/#{params[:github_repository]}".red
        end

        labels = [params[:added_label_name], params[:updated_label_name], params[:changed_label_name], params[:fixed_label_name], params[:removed_label_name]]
        sections = Array.new
        labels.each do |label_name|
          subissues = issues.select {|issue| issue["labels"].any? {|label| label["name"].downcase == label_name.downcase}}
          if subissues.count > 0
            sections << {section: label_name, issues: subissues}
            issues = issues - subissues
          end
        end

        if issues.count > 0
          prompt_text = "There are #{issues.count} issue(s) that have not been properly categorized in this milestone. Do you want to continue?"
          if Fastlane::Actions::PromptAction.run(text: prompt_text, boolean: true, ci_input: "y")
            if sections.count > 0
              section_label = "Additional Changes"
            else
              section_label = "Changes"
            end
            sections << {section: section_label, issues: issues}
          else
            raise "Aborting since issues have not been categorized."
          end
          
        end
        
        
        date = DateTime.now
        result = Hash.new
        result[:title] = "\n\n## [#{params[:milestone]}](https://github.com/#{params[:github_owner]}/#{params[:github_repository]}/releases/tag/#{params[:milestone]}) (#{date.strftime("%m/%d/%Y")})"
        result[:header] = "\nReleased on #{date.strftime("%A, %B %d, %Y")}. All issues associated with this milestone can be found using this [filter](https://github.com/#{params[:github_owner]}/#{params[:github_repository]}/issues?q=milestone%3A#{params[:milestone]}+is%3Aclosed)."
        
        result[:changelog] = "\n"
        sections.each do |section|
          result[:changelog] << markdown_for_changelog_section(params[:github_owner], params[:github_repository], params[:api_token], section[:section], section[:issues])
        end
        Actions.lane_context[SharedValues::GITHUB_MILESTONE_CHANGELOG] = result
        
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generate a markdown formatted change log for a specific milestone in a Github repository"
      end

      def self.details

        "You can use this action to do cool things..."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :github_owner,
                                       env_name: "GITHUB_OWNER", 
                                       description: "Github Owner for the repository",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :github_repository,
                                       env_name: "GITHUB_REPOSITORY",
                                       description: "Github Repository containing the milestone",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "GITHUB_API_TOKEN",
                                       description: "Personal API Token for GitHub - generate one at https://github.com/settings/tokens",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :milestone,
                                       env_name: "FL_GENERATE_GITHUB_MILESTONE_CHANGELOG_MILESTONE",
                                       description: "Milestone to generate changelog notes",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :added_label_name,
                                       env_name: "FL_GENERATE_GITHUB_MILESTONE_CHANGELOG_ADDED_LABEL_NAME",
                                       description: "Github label name for all issues added during this milestone",
                                       is_string: true,
                                       default_value: "Added"),
          FastlaneCore::ConfigItem.new(key: :updated_label_name,
                                       env_name: "FL_GENERATE_GITHUB_MILESTONE_CHANGELOG_UPDATED_LABEL_NAME",
                                       description: "Github label name for all issues updated during this milestone",
                                       is_string: true,
                                       default_value: "Updated"),
          FastlaneCore::ConfigItem.new(key: :changed_label_name,
                                       env_name: "FL_GENERATE_GITHUB_MILESTONE_CHANGELOG_CHANGED_LABEL_NAME",
                                       description: "Github label name for all issues changed during this milestone",
                                       is_string: true,
                                       default_value: "Changed"),
          FastlaneCore::ConfigItem.new(key: :fixed_label_name,
                                       env_name: "FL_GENERATE_GITHUB_MILESTONE_CHANGELOG_FIXED_LABEL_NAME",
                                       description: "Github label name for all issues fixed during this milestone",
                                       is_string: true,
                                       default_value: "Fixed"),
          FastlaneCore::ConfigItem.new(key: :removed_label_name,
                                       env_name: "FL_GENERATE_GITHUB_MILESTONE_CHANGELOG_REMOVED_LABEL_NAME",
                                       description: "Github label name for all removed added during this milestone",
                                       is_string: true,
                                       default_value: "Removed"),
          FastlaneCore::ConfigItem.new(key: :allow_empty_changelog,
                                       env_name: "FL_GENERATE_GITHUB_MILESTONE_CHANGELOG_ALLOW_EMPTY",
                                       description: "Flag which allows an empty changelog. If false, exception is raised if no issues are found",
                                       is_string: false,
                                       default_value: true)                                       
        ]
      end

      def self.output
        [
          ['GITHUB_MILESTONE_CHANGELOG', 'A hash containing a well formatted :header, and the :changelog itself']
        ]
      end

      def self.return_value
        "Returns a hash containing a well formatted :title, :header, and the :changelog itself, both in markdown"
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
