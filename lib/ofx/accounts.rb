module OFX
  class Accounts < Array
    def find_by_transaction(transaction)
      find(transaction.account_id)
    end

    def find(id)
      detect { |account| account.id == id }
    end

    def to_hash
      map { |account| account.to_hash }
    end
  end
end
