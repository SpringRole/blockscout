defmodule BlockScoutWeb.ContractsController do
    use BlockScoutWeb, :controller

    alias Explorer.{Chain, PagingOptions}
    alias Explorer.Chain.Hash
    alias Phoenix.View
    alias BlockScoutWeb.Call
  

    def index(conn, _params) do
        with true <- ajax?(conn) do
            recent_transactions =
                Chain.recent_collated_transactions(
                    necessity_by_association: %{
                        :block => :required,
                        [created_contract_address: :names] => :optional,
                        [from_address: :names] => :required,
                        [to_address: :names] => :optional
                    },
                    paging_options: %PagingOptions{page_size: 5}
                )

            #Fetch contract addresses 
            contract_address = Call.contract_addresses()
            {:ok, attestationOne } = Map.fetch(contract_address, :AttestationOne)
            {:ok, attestationTwo } = Map.fetch(contract_address, :AttestationTwo)
            {:ok, vanityOne } = Map.fetch(contract_address, :VanityOne)
            {:ok, vanityTwo } = Map.fetch(contract_address, :VanityTwo)

            contract_transactions =
                Enum.filter(recent_transactions, fn transaction ->
                    
                    transaction_address = transaction |> BlockScoutWeb.AddressView.address_partial_selector(:to, :current_address) |> BlockScoutWeb.RenderHelpers.render_partial()
          
                    {:ok, tx_address_1 } = Enum.fetch(List.first(elem(transaction_address, 1)), 1)
                    {:ok, tx_address_2 } = Enum.fetch(tx_address_1, 2)
                    tx_address = String.slice(List.to_string(tx_address_2), 46, 42)
                    
                    (transaction_address == attestationOne or transaction_address == attestationTwo or transaction_address == vanityOne or transaction_address == vanityTwo)
                end)

            transactions =  
                Enum.map(contract_transactions, fn transaction ->
                    transaction_address = transaction |> BlockScoutWeb.AddressView.address_partial_selector(:to, :current_address) |> BlockScoutWeb.RenderHelpers.render_partial()
                    
                    {:ok, tx_address_1 } = Enum.fetch(List.first(elem(transaction_address, 1)), 1)
                    {:ok, tx_address_2 } = Enum.fetch(tx_address_1, 2)
                    tx_address = String.slice(List.to_string(tx_address_2), 46, 42)

                    if (tx_address == attestationOne or tx_address == attestationTwo) do
                        %{
                            transaction_hash: Hash.to_string(transaction.hash),
                            contract_html: View.render_to_string(BlockScoutWeb.ContractsView, "_tile_contract_transaction.html",
                                contractType: "Work Experience Verification",
                                transaction: transaction,
                                hash: Hash.to_string(transaction.hash)
                            )
                        }
                    end 
                    if (tx_address == vanityOne or tx_address == vanityTwo) do
                        %{
                            transaction_hash: Hash.to_string(transaction.hash),
                            contract_html: View.render_to_string(BlockScoutWeb.ContractsView, "_tile_contract_transaction.html",
                                contractType: "Vanity Reservation",
                                transaction: transaction,
                                hash: Hash.to_string(transaction.hash)
                            )
                        }                        
                    end

                end)   

                
                json(conn, %{transactions: transactions})

        else
          _ -> unprocessable_entity(conn)
        end
    end
end