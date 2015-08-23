module SaltParser
  module Ofx
    class SignOn < SaltParser::Base
      attr_accessor :language, :fi_id, :fi_name, :code, :severity, :message

      def to_hash
        {
          :language => language,
          :fi_id    => fi_id,
          :fi_name  => fi_name,
          :code     => code,
          :severity => severity,
          :message  => message
        }
      end
    end
  end
end
