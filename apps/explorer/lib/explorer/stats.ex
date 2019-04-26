defmodule Explorer.Stats do

    alias Explorer.Repo

    import Ecto.Query, only: [from: 2]


    
    def attestation_count() do
        query = from(l in "logs",
                where: l.address_hash == "\\x793B214053B72A967077364af5eF3d32d32CE9Ea",
                select: count("*")
        )

        Repo.one(query) 
        
    end
    
    
    def vanity_count() do
        query = from(l in "logs",
                where: l.address_hash == "\\x76a8F13c42fa41dB608b2beE23e73f1Dbe540cD5",
                select: count("*")
        )

        Repo.one(query)
    end

    def transaction_time() do
        query = from(l in "logs",
                where: l.address_hash == "\\x793B214053B72A967077364af5eF3d32d32CE9Ea" or l.address_hash == "\\x76a8F13c42fa41dB608b2beE23e73f1Dbe540cD5",
                select: l.inserted_at,
                order_by: [desc: l.inserted_at],
                limit: 1
        )
        
       NaiveDateTime.diff(NaiveDateTime.utc_now ,Repo.one(query))/60
    end

    
end

 
