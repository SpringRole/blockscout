defmodule BlockScoutWeb.Call do

    def single_transaction(transaction_hash) do
        {:ok, response} = Tesla.get("http://localhost:3010/blockscout/api/v2/Transactions/" <> transaction_hash)
        response.body
    end

    def multiple_transactions(transaction_hash_array) do
        {:ok, response} = Tesla.get("http://localhost:3010/blockscout/api/v2/ViewAllTransactions?transactions=" <> transaction_hash_array)
        response.body
    end

  

    def contract_addresses() do 
        %{
            :AttestationOne => "0xe2f6cca92c16bbdd99df98c837b3bc4955184f50",
            :AttestationTwo => "0x4b9203cdfc252895172b602b096ab417a7c3004c",
            :VanityOne => "0x8cafc3eb956b95a3a0bccbc31cedd8042b2c45a8",
            :VanityTwo => "0x8b1874f99b7fab5d018cb88dd00134cabb1ec483"
        }
    end

end