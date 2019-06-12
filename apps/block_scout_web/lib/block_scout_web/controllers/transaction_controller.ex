defmodule BlockScoutWeb.TransactionController do
  use BlockScoutWeb, :controller

  import BlockScoutWeb.Chain, only: [paging_options: 1, next_page_params: 3, split_list_by_page: 1]

  alias BlockScoutWeb.TransactionView
  alias Explorer.Chain
  alias Phoenix.View
  alias BlockScoutWeb.Call
  alias Explorer.Chain.Hash

  def index(conn, %{"type" => "JSON"} = params) do
    full_options =
      Keyword.merge(
        [
          necessity_by_association: %{
            :block => :required,
            [created_contract_address: :names] => :optional,
            [from_address: :names] => :optional,
            [to_address: :names] => :optional
          }
        ],
        paging_options(params)
      )

    transactions_plus_one = Chain.recent_collated_transactions(full_options)
    {transactions, next_page} = split_list_by_page(transactions_plus_one)

    next_page_path =
      case next_page_params(next_page, transactions, params) do
        nil ->
          nil

        next_page_params ->
          transaction_path(conn, :index, Map.delete(next_page_params, "type"))
      end

      #Fetch contract addresses 
    contract_address = Call.contract_addresses()
    {:ok, attestationOne } = Map.fetch(contract_address, :AttestationOne)
    {:ok, attestationTwo } = Map.fetch(contract_address, :AttestationTwo)
    {:ok, vanityOne } = Map.fetch(contract_address, :VanityOne)
    {:ok, vanityTwo } = Map.fetch(contract_address, :VanityTwo)

    #Create the list of transactions to be rendered
    transactions_to_be_rendered = 
      Enum.map(transactions, fn transaction -> 
        
        #Fetch the "to" address of transaction
        transaction_address = transaction |> BlockScoutWeb.AddressView.address_partial_selector(:to, :current_address) |> BlockScoutWeb.RenderHelpers.render_partial()
        contract_address = Call.contract_addresses()
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
                  attestedByUserMap = attestedByUserMapping(data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address, workExResult, workExDetails, tx)
                "company" ->
                  attestedByCompanyMap = attestedByCompanyMapping(data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address, workExResult, workExDetails, tx)
                end

              
            "Vanity Reservation" ->
              vanityMap = vanityMapping(data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address)


            "Null" -> 
                %{
                  transaction: transaction,
                  attestationOne: attestationOne,
                  attestationTwo: attestationTwo,
                  vanityOne: vanityOne,
                  vanityTwo: vanityTwo,
                  tx_address: tx_address,
                  hash: Hash.to_string(transaction.hash),
                  data: data,                               
                  workExResult: "",
                  tx: "",
                  companyName: "",
                  attestedUserFullName: "",
                  attestedUserDesignation: "",
                  profileHeadlineType: "",
                  attestingUserFullName: "",
                  attestingCompanyName: "",
                  vanityUserFullName: "",
                  userVanityURL: ""                
                }  
          end 

          
        else       
          %{
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
            tx: "",
            companyName: "",
            attestedUserFullName: "",
            attestedUserDesignation: "", 
            profileHeadlineType: "",  
            attestingUserFullName: "",
            attestingCompanyName: "",
            vanityUserFullName: "",
            userVanityURL: ""                               
          }
        end
      end) 
      

    json(
      conn,
      %{
        items:
          Enum.map(transactions_to_be_rendered, fn transaction ->
            View.render_to_string(
              TransactionView,
              "_tile_transactions_list.html",
              transaction: transaction
            )
          end),
        next_page_path: next_page_path
      }
    )
  end 

    def attestedByUserMapping(data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address, workExResult, workExDetails, tx) do
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
        transaction: transaction,
        attestationOne: attestationOne,
        attestationTwo: attestationTwo,
        vanityOne: vanityOne,
        vanityTwo: vanityTwo,
        tx_address: tx_address,
        hash: Hash.to_string(transaction.hash),
        data: data, 
        workExResult: workExResult,
        tx: tx,
        companyName: companyName,
        attestedUserFullName: attestedUserFullName,
        attestedUserDesignation: attestedUserDesignation,
        profileHeadlineType: profileHeadlineType,
        attestingUserFullName: attestingUserFullName,
        attestingCompanyName: "",
        vanityUserFullName: "",
        userVanityURL: ""                  
      }
    end

    def attestedByCompanyMapping(data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address, workExResult, workExDetails, tx) do
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
        transaction: transaction,
        attestationOne: attestationOne,
        attestationTwo: attestationTwo,
        vanityOne: vanityOne,
        vanityTwo: vanityTwo,
        tx_address: tx_address,
        hash: Hash.to_string(transaction.hash),
        data: data,
        workExResult: workExResult,
        tx: tx,
        companyName: companyName,
        attestedUserFullName: attestedUserFullName,
        attestedUserDesignation: attestedUserDesignation,
        profileHeadlineType: profileHeadlineType,
        attestingUserFullName: "",
        attestingCompanyName: attestingCompanyName,
        vanityUserFullName: "",
        userVanityURL: ""
      }
    end
    
    def vanityMapping(data, transaction, attestationOne, attestationTwo, vanityOne, vanityTwo, tx_address) do
      {:ok, vanityResult} = Map.fetch(data, "vanityResult")
      {:ok, userName} = Map.fetch(vanityResult, "name")
      {:ok, vanityUserFullName} = Map.fetch(userName, "full")
      {:ok, userVanityURL} = Map.fetch(vanityResult, "vanity_url")
      
      %{
        transaction: transaction,
        attestationOne: attestationOne,
        attestationTwo: attestationTwo,
        vanityOne: vanityOne,
        vanityTwo: vanityTwo,
        tx_address: tx_address,
        hash: Hash.to_string(transaction.hash),
        data: data,
        workExResult: "",
        tx: "",
        companyName: "",
        attestedUserFullName: "",
        attestedUserDesignation: "",
        profileHeadlineType: "",
        attestingUserFullName: "",
        attestingCompanyName: "",
        vanityUserFullName: vanityUserFullName,
        userVanityURL: userVanityURL
      }
    end




  def index(conn, _params) do
    transaction_estimated_count = Chain.transaction_estimated_count()

    render(
      conn,
      "index.html",
      current_path: current_path(conn),
      transaction_estimated_count: transaction_estimated_count
    )
  end

  def show(conn, %{"id" => id}) do
    case Chain.string_to_transaction_hash(id) do
      {:ok, transaction_hash} -> show_transaction(conn, id, Chain.hash_to_transaction(transaction_hash))
      :error -> conn |> put_status(422) |> render("invalid.html", transaction_hash: id)
    end
  end

  defp show_transaction(conn, id, {:error, :not_found}) do
    conn |> put_status(404) |> render("not_found.html", transaction_hash: id)
  end

  defp show_transaction(conn, id, {:ok, %Chain.Transaction{} = transaction}) do
    if Chain.transaction_has_token_transfers?(transaction.hash) do
      redirect(conn, to: transaction_token_transfer_path(conn, :index, id))
    else
      redirect(conn, to: transaction_internal_transaction_path(conn, :index, id))
    end
  end
end
