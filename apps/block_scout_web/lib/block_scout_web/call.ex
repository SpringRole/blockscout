defmodule BlockScoutWeb.Call do

    def single_transaction(transaction_hash) do
        {:ok, response} = Tesla.get("http://localhost:3010/blockscout/api/v2/Transactions/" <> transaction_hash)
        response.body
    end

    def multiple_transactions(transaction_hash_array) do
        {:ok, response} = Tesla.get("http://localhost:3010/blockscout/api/v2/ViewAllTransactions?transactions=" <> transaction_hash_array)
        response.body
    end


end