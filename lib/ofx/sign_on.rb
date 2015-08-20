module OFX
  class SignOn < Base
    attr_accessor :language
    attr_accessor :fi_id
    attr_accessor :fi_name
    attr_accessor :code
    attr_accessor :severity
    attr_accessor :message

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
