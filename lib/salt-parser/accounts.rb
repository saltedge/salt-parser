module SaltParser
  class Accounts < Array
    def find(identifier)
      detect { |account| account.identifier == identifier }
    end

    def to_hash
      map { |account| account.to_hash }
    end
  end
end
