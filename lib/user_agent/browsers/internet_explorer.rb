class UserAgent
  module Browsers
    class InternetExplorer < Base
      def self.extend?(agent)
        agent.application &&
        agent.application.comment &&
        (agent.application.comment[1] =~ /MSIE/ ||
         agent.application.comment.join('; ') =~ /Trident.+rv:/)
      end

      def browser
        "Internet Explorer"
      end

      def version
        str = application.comment.join('; ')[/(MSIE\s|rv:)([\d\.]+)/, 2]
        Version.new(str)
      end

      def trident_version
        if trident = application.comment.detect { |c| c['Trident/'] }
          trident_engines = Hash.new(trident).merge({
            "Trident/7.0" => "11.0",
            "Trident/6.0" => "10.0",
            "Trident/5.0" => "9.0",
            "Trident/4.0" => "8.0"
          })
          trident_engines[trident] && Version.new(trident_engines[trident])
        end
      end

      def real_version
        [trident_version, version].sort.last
      end

      def compatibility_view?
        version < real_version
      end

      # Before version 4.0, Chrome Frame declared itself (unversioned) in a comment;
      # as of 4.0 it can declare itself versioned in a comment
      # or as a separate product with a version
      def chromeframe
        cf = application.comment.include?("chromeframe") || detect_product("chromeframe")
        return cf if cf
        cf_comment = application.comment.detect { |c| c['chromeframe/'] }
        cf_comment ? UserAgent.new(*cf_comment.split('/', 2)) : nil
      end

      def platform
        "Windows"
      end

      def os
        OperatingSystems.normalize_os(application.comment.join('; ').match(/Windows NT [\d\.]+|Windows Phone (OS )?[\d\.]+/).to_s)
      end
    end
  end
end
