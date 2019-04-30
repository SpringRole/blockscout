defmodule BlockScoutWeb.Call do
  

    def single_transaction(transaction_hash) do
        Tesla.get("http://localhost:3010/blockscout/api/v2/Transactions/" <> transaction_hash)
    end

    def api_call() do
        {:ok, response} = single_transaction("0xdbd3b487ff78cfd19e9e4cf07037cc5712db578f211601145508dc04ada6395a")
        response.body
    end

end