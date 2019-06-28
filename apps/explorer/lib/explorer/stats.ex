defmodule Explorer.Stats do

    alias Explorer.Repo
    import Ecto.Query, only: [from: 2]
  
    def attestation_count() do
        query = from(l in "logs",
                where: l.address_hash == "\\xe2f6cca92c16bbdd99df98c837b3bc4955184f50" or l.address_hash == "\\x4b9203cdfc252895172b602b096ab417a7c3004c",
                select: count("*")
        )
        Repo.one(query)    
    end
    
    
    def vanity_count() do
        query = from(l in "logs",
                where: l.address_hash == "\\x8cafc3eb956b95a3a0bccbc31cedd8042b2c45a8" or l.address_hash == "\\x8b1874f99b7fab5d018cb88dd00134cabb1ec483",
                select: count("*")
        )
        Repo.one(query)
    end

    def transaction_time() do
        query = from(l in "logs",
                select: l.inserted_at,
                order_by: [desc: l.inserted_at],
                limit: 1
        )
        
       NaiveDateTime.diff(NaiveDateTime.utc_now, Repo.one(query), :seconds)/60
       |> Float.round(2)
    end

    
end

 
