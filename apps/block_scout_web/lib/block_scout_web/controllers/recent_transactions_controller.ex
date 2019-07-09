defmodule BlockScoutWeb.RecentTransactionsController do
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

      #Create the list of transactions to be rendered
      transactions = 
        Enum.map(recent_transactions, fn transaction -> 
          
          #Fetch the "to" address of transaction
          transaction_address = transaction |> BlockScoutWeb.AddressView.address_partial_selector(:to, :current_address) |> BlockScoutWeb.RenderHelpers.render_partial()
          
          {:ok, tx_address_1 } = Enum.fetch(List.first(elem(transaction_address, 1)), 1)
          {:ok, tx_address_2 } = Enum.fetch(tx_address_1, 2)
          tx_address = String.slice(List.to_string(tx_address_2), 46, 42)
          
        
          if(tx_address == attestationTwo or tx_address == vanityOne or tx_address == attestationOne or tx_address == vanityTwo) do
            response = Call.single_transaction(Hash.to_string(transaction.hash))
            payload = Jason.decode!(response)
            {:ok, data} = Map.fetch(payload, "data")


            case data["txType"] do
              "Attestation" ->
                {:ok, workExResult} = Map.fetch(data, "workExResult")
                {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
                {:ok, tx} = Map.fetch(workExDetails, "tx")

                case tx["signed_by_type"] do
                  "user" -> 
                    attestedByUserMap = attestedByUserMapping(conn, data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address, workExResult, workExDetails, tx)
                  "company" ->
                    attestedByCompanyMap = attestedByCompanyMapping(conn, data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address, workExResult, workExDetails, tx)
                end
              
              "Vanity Reservation" -> 
                vanityMap = vanityMapping(conn, data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address)       
              
              "Null" ->
                
                %{
                  transaction_hash: Hash.to_string(transaction.hash),
                  transaction_html:
                    View.render_to_string(BlockScoutWeb.TransactionView, "_tile_recent_transactions.html", 
                      conn: conn,
                      transaction: transaction,
                      attestationOne: attestationOne,
                      attestationTwo: attestationTwo,
                      vanityOne: vanityOne,
                      vanityTwo: vanityTwo,
                      tx_address: tx_address,
                      hash: Hash.to_string(transaction.hash),
                      data: data,                               
                      workExResult: "",
                      companyName: "",
                      attestedUserFullName: "",
                      attestedUserDesignation: "",
                      profileHeadlineType: "",
                      attestingUserFullName: "",
                      attestingCompanyName: "",
                      vanityUserFullName: "",
                      userVanityURL: ""
                    )
                }
            end
          else 
            
            %{
              transaction_hash: Hash.to_string(transaction.hash),
              transaction_html:
                View.render_to_string(BlockScoutWeb.TransactionView, "_tile_recent_transactions.html", 
                  conn: conn,
                  transaction: transaction,
                  attestationOne: attestationOne,
                  attestationTwo: attestationTwo,
                  vanityOne: vanityOne,
                  vanityTwo: vanityTwo,
                  tx_address: tx_address,
                  hash: Hash.to_string(transaction.hash),  
                  data: %{
                    "payload" => "Not a contract call"
                  }, 
                  workExResult: "",
                  companyName: "",
                  attestedUserFullName: "",
                  attestedUserDesignation: "", 
                  profileHeadlineType: "",  
                  attestingUserFullName: "",
                  attestingCompanyName: "",
                  vanityUserFullName: "",
                  userVanityURL: ""                               
                )
            }
          end
        end) 

        json(conn, %{transactions: transactions})
    else
      _ -> unprocessable_entity(conn)
    end
  end

  def attestedByUserMapping(conn, data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address, workExResult, workExDetails, tx) do
    {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
    {:ok, company} = Map.fetch(workExDetails, "company")
    {:ok, companyName} = Map.fetch(company, "name")    
    {:ok, attestedUserDetails} = Map.fetch(workExResult, "attestedUserDetails")
    {:ok, attestedUserName} = Map.fetch(attestedUserDetails, "name")
    {:ok, attestedUserFullName} = Map.fetch(attestedUserName, "full") 
    {:ok, profileHeadlineType} = Map.fetch(attestedUserDetails, "profile_headline_type")  
    {:ok, attestedUserDesignation} = Map.fetch(attestedUserDetails, "designation")
    {:ok, attestingUserDetails} = Map.fetch(workExResult, "attestingUserDetails")
    {:ok, attestingUserName} = Map.fetch(attestingUserDetails, "name") 
    {:ok, attestingUserFullName} = Map.fetch(attestingUserName, "full")

    %{
      transaction_hash: transaction.hash,
      transaction_html:
        View.render_to_string(BlockScoutWeb.TransactionView, "_tile.html", 
          conn: conn,
          transaction: transaction,
          attestationOne: attestationOne,
          attestationTwo: attestationTwo,
          vanityOne: vanityOne,
          vanityTwo: vanityTwo,
          tx_address: tx_address,
          hash: Hash.to_string(transaction.hash),
          data: data, 
          workExResult: workExResult,
          companyName: companyName,
          attestedUserFullName: attestedUserFullName,
          attestedUserDesignation: attestedUserDesignation,
          profileHeadlineType: profileHeadlineType,
          attestingUserFullName: attestingUserFullName,
          attestingCompanyName: "",
          vanityUserFullName: "",
          userVanityURL: ""
        )   
    }

  end

  def attestedByCompanyMapping(conn, data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address, workExResult, workExDetails, tx) do
    {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
    {:ok, company} = Map.fetch(workExDetails, "company")
    {:ok, companyName} = Map.fetch(company, "name")
    {:ok, attestedUserDetails} = Map.fetch(workExResult, "attestedUserDetails")
    {:ok, attestedUserName} = Map.fetch(attestedUserDetails, "name")
    {:ok, attestedUserFullName} = Map.fetch(attestedUserName, "full")
    {:ok, profileHeadlineType} = Map.fetch(attestedUserDetails, "profile_headline_type")
    {:ok, attestedUserDesignation} = Map.fetch(attestedUserDetails, "designation")
    {:ok, attestingCompanyDetails} = Map.fetch(workExResult, "attestingCompanyDetails")
    {:ok, attestingCompanyName} = Map.fetch(attestingCompanyDetails, "name") 

    %{
      transaction_hash: transaction.hash,
      transaction_html:
        View.render_to_string(BlockScoutWeb.TransactionView, "_tile_recent_transactions.html", 
          conn: conn,
          transaction: transaction,
          attestationOne: attestationOne,
          attestationTwo: attestationTwo,
          vanityOne: vanityOne,
          vanityTwo: vanityTwo,
          tx_address: tx_address,
          hash: Hash.to_string(transaction.hash),
          data: data,
          workExResult: workExResult,
          companyName: companyName,
          attestedUserFullName: attestedUserFullName,
          attestedUserDesignation: attestedUserDesignation,
          profileHeadlineType: profileHeadlineType,
          attestingUserFullName: "",
          attestingCompanyName: attestingCompanyName,
          vanityUserFullName: "",
          userVanityURL: ""
        )
    }
  end

  def vanityMapping(conn, data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address) do
    {:ok, vanityResult} = Map.fetch(data, "vanityResult")
    {:ok, userName} = Map.fetch(vanityResult, "name")
    {:ok, vanityUserFullName} = Map.fetch(userName, "full")
    {:ok, userVanityURL} = Map.fetch(vanityResult, "vanity_url")
    
    %{
      transaction_hash: transaction.hash,
      transaction_html:
        View.render_to_string(BlockScoutWeb.TransactionView, "_tile_recent_transactions.html", 
          conn: conn,  
          transaction: transaction,
          attestationOne: attestationOne,
          attestationTwo: attestationTwo,
          vanityOne: vanityOne,
          vanityTwo: vanityTwo,
          tx_address: tx_address,
          hash: Hash.to_string(transaction.hash),
          data: data,
          workExResult: "",
          companyName: "",
          attestedUserFullName: "",
          attestedUserDesignation: "",
          profileHeadlineType: "",
          attestingUserFullName: "",
          attestingCompanyName: "",
          vanityUserFullName: vanityUserFullName,
          userVanityURL: userVanityURL
        )
    }
  end

end