defmodule BlockScoutWeb.TransactionInternalTransactionController do
  use BlockScoutWeb, :controller

  import BlockScoutWeb.Chain, only: [paging_options: 1, next_page_params: 3, split_list_by_page: 1]
  alias BlockScoutWeb.Call
  alias BlockScoutWeb.TransactionView
  alias Explorer.{Chain, Market}
  alias Explorer.ExchangeRates.Token
  
  def index(conn, params = %{"transaction_id" => hash_string}) do
    with {:ok, hash} <- Chain.string_to_transaction_hash(hash_string),
         {:ok, transaction} <-
           Chain.hash_to_transaction(
             hash,
             necessity_by_association: %{
               :block => :optional,
               [created_contract_address: :names] => :optional,
               [from_address: :names] => :optional,
               [to_address: :names] => :optional,
               [to_address: :smart_contract] => :optional,
               :token_transfers => :optional
             }
           ) do
      full_options =
        Keyword.merge(
          [
            necessity_by_association: %{
              [created_contract_address: :names] => :optional,
              [from_address: :names] => :optional,
              [to_address: :names] => :optional
            }
          ],
          paging_options(params)
        )

        full_options_logs =
        Keyword.merge(
          [
            necessity_by_association: %{
              address: :optional
            }
          ],
          paging_options(params)
        )

      internal_transactions_plus_one = Chain.transaction_to_internal_transactions(transaction, full_options)

      {internal_transactions, next_page} = split_list_by_page(internal_transactions_plus_one)
      logs_plus_one = Chain.transaction_to_logs(transaction, full_options_logs)

      {logs, next_page} = split_list_by_page(logs_plus_one)



      {:ok, hash_string} = Map.fetch(params, "transaction_id")
      response =  Call.single_transaction(hash_string)
      payload = Jason.decode!(response)

      {:ok, data} = Map.fetch(payload, "data")

      case data["txType"] do
        "Attestation" ->
          attestationRender(conn, data, internal_transactions, transaction, logs, hash, next_page, params)
        "Vanity Reservation" ->
          vanityRender(conn, data, internal_transactions, transaction, logs, hash, next_page, params)
        "Null" -> 
          render(
            conn,
            "index.html",
            exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
            internal_transactions: internal_transactions,
            block_height: Chain.block_height(),
            show_token_transfers: Chain.transaction_has_token_transfers?(hash),
            next_page_params: next_page_params(next_page, internal_transactions, params),
            transaction: transaction
          ) 
      end
    else
      :error ->
        conn
        |> put_status(422)
        |> put_view(TransactionView)
        |> render("invalid.html", transaction_hash: hash_string)

      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> put_view(TransactionView)
        |> render("not_found.html", transaction_hash: hash_string)
    end
  end

    
  def vanityRender(conn, data, internal_transactions, transaction, logs, hash, next_page, params) do
    {:ok, vanityResult} = Map.fetch(data, "vanityResult")
        {:ok, userName} = Map.fetch(vanityResult, "name")
        {:ok, userFullName} = Map.fetch(userName, "full")
        {:ok, userLogoURL} = Map.fetch(vanityResult, "avatar_url")
        {:ok, userVanityURL} = Map.fetch(vanityResult, "vanity_url")
        {:ok, transactionHash} = Map.fetch(vanityResult, "transaction_hash")
        {:ok, userHeadLine} = Map.fetch(vanityResult, "userHeadLine")
        if(Map.has_key?(userHeadLine, "text")) do
           {:ok, userHeadLineText} = Map.fetch(userHeadLine, "text")

          if(userHeadLineText == "null") do
            render(
              conn, 
              "transactionDetailsVanity.html",
              transaction: transaction,
              logs: logs,
              userFullName: userFullName,
              userLogoURL: userLogoURL,
              userVanityURL: userVanityURL,
              transactionHash: transactionHash,
              exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
              internal_transactions: internal_transactions,
              userHeadLineText: "",
              userHeadLineCompany: "",
              userHeadLineLocation: "",
              block_height: Chain.block_height(),
              show_token_transfers: Chain.transaction_has_token_transfers?(hash),
              next_page_params: next_page_params(next_page, internal_transactions, params),
            )
          end

          {:ok, userHeadLineText} = Map.fetch(userHeadLine, "text")
          {:ok, userHeadLineLocation} = Map.fetch(userHeadLine, "location_name")
          {:ok, userHeadLineCompany} = Map.fetch(userHeadLine, "company")

          render(
              conn, 
              "transactionDetailsVanity.html",
              transaction: transaction,
              logs: logs,
              userFullName: userFullName,
              userLogoURL: userLogoURL,
              userVanityURL: userVanityURL,
              transactionHash: transactionHash,
              exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
              internal_transactions: internal_transactions,
              userHeadLineText: userHeadLineText,
              userHeadLineCompany: userHeadLineCompany,
              userHeadLineLocation: userHeadLineLocation,
              block_height: Chain.block_height(),
              show_token_transfers: Chain.transaction_has_token_transfers?(hash),
              next_page_params: next_page_params(next_page, internal_transactions, params),
            )
        
        else
          render(
              conn, 
              "transactionDetailsVanity.html",
              transaction: transaction,
              logs: logs,
              userFullName: userFullName,
              userLogoURL: userLogoURL,
              userVanityURL: userVanityURL,
              transactionHash: transactionHash,
              exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
              internal_transactions: internal_transactions,
              userHeadLineText: "",
              userHeadLineCompany: "",
              userHeadLineLocation: "",
              block_height: Chain.block_height(),
              show_token_transfers: Chain.transaction_has_token_transfers?(hash),
              next_page_params: next_page_params(next_page, internal_transactions, params),
            )
        end

  end

  def attestationRender(conn, data, internal_transactions, transaction, logs, hash, next_page, params) do
    {:ok, workExResult} = Map.fetch(data, "workExResult")
          if(Map.has_key?(workExResult, "attestingUserDeatils")) do

            {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
            {:ok, tx} = Map.fetch(workExDetails, "tx")
            {:ok, company} = Map.fetch(workExDetails, "company")
            {:ok, companyName} = Map.fetch(company, "name")
            {:ok, transactionType} = Map.fetch(tx, "transaction_type")
            {:ok, transactionHash} = Map.fetch(tx, "transaction_hash")
            {:ok, attestedUserDetails} = Map.fetch(workExResult, "attestedUserDetails")
            {:ok, attestedUserName} = Map.fetch(attestedUserDetails, "name")
            {:ok, attestedUserFullName} = Map.fetch(attestedUserName, "full")
            {:ok, attestedUserLogoURL} = Map.fetch(attestedUserDetails, "avatar_url")
            {:ok, attestedUserDesignation} = Map.fetch(attestedUserDetails, "designation")
            {:ok, userHeadLine} = Map.fetch(attestedUserDetails, "userHeadLine")
            {:ok, attestingUserDeatils} = Map.fetch(workExResult, "attestingUserDeatils")
            {:ok, attestingUserOrCompanyName} = Map.fetch(attestingUserDeatils, "name") 
            {:ok, attestingUserOrCompanyFullName} = Map.fetch(attestingUserOrCompanyName, "full")     
            {:ok, attestingUserOrCompanyLogoURL} = Map.fetch(attestingUserDeatils, "avatar_url")
            {:ok, profileHeadlineType} = Map.fetch(attestedUserDetails, "profile_headline_type")
            if(profileHeadlineType == "null") do
                render(
                    conn,
                    "transactionDetailsAttestation.html",
                    transactionType: transactionType,
                    transactionHash: transactionHash,
                    attestedUserFullName: attestedUserFullName,
                    companyName: companyName,
                    attestedUserDesignation: attestedUserDesignation,
                    userHeadLineText: "",
                    userHeadLineCompany: "",
                    userHeadLineLocation: "",
                    attestedUserLogoURL: attestedUserLogoURL,
                    attestingUserOrCompanyFullName: attestingUserOrCompanyFullName,
                    attestingUserOrCompanyLogoURL: attestingUserOrCompanyLogoURL,
                    profileHeadlineType: profileHeadlineType,
                    next_page_params: next_page_params(next_page, internal_transactions, params),
                    transaction: transaction,
                    logs: logs
                )
            end
            {:ok, userHeadLineText} = Map.fetch(userHeadLine, "text")
            {:ok, userHeadLineLocation} = Map.fetch(userHeadLine, "location_name")
            {:ok, userHeadLineCompany} = Map.fetch(userHeadLine, "company")
            


            render(
                conn,
                "transactionDetailsAttestation.html",
                transactionType: transactionType,
                transactionHash: transactionHash,
                attestedUserFullName: attestedUserFullName,
                companyName: companyName,
                attestedUserDesignation: attestedUserDesignation,
                userHeadLineText: userHeadLineText,
                userHeadLineCompany: userHeadLineCompany,
                userHeadLineLocation: userHeadLineLocation,
                attestedUserLogoURL: attestedUserLogoURL,
                attestingUserOrCompanyFullName: attestingUserOrCompanyFullName,
                attestingUserOrCompanyLogoURL: attestingUserOrCompanyLogoURL,
                profileHeadlineType: profileHeadlineType,
                exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
                internal_transactions: internal_transactions,
                block_height: Chain.block_height(),
                show_token_transfers: Chain.transaction_has_token_transfers?(hash),
                next_page_params: next_page_params(next_page, internal_transactions, params),
                transaction: transaction,
                logs: logs
            )
          end



          if(Map.has_key?(workExResult, "attestingCompanyDeatils")) do

                
            {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
            {:ok, tx} = Map.fetch(workExDetails, "tx")
            {:ok, company} = Map.fetch(workExDetails, "company")
            {:ok, companyName} = Map.fetch(company, "company_name")
            {:ok, transactionType} = Map.fetch(tx, "transaction_type")
            {:ok, transactionHash} = Map.fetch(tx, "transaction_hash")
            {:ok, attestedUserDetails} = Map.fetch(workExResult, "attestedUserDetails")
            {:ok, attestedUserName} = Map.fetch(attestedUserDetails, "name")
            {:ok, attestedUserFullName} = Map.fetch(attestedUserName, "full")
            {:ok, attestedUserLogoURL} = Map.fetch(attestedUserDetails, "avatar_url")
            {:ok, attestedUserDesignation} = Map.fetch(attestedUserDetails, "designation")
            {:ok, userHeadLine} = Map.fetch(attestedUserDetails, "userHeadLine")
            {:ok, attestingCompanyDeatils} = Map.fetch(workExResult, "attestingCompanyDeatils")
            {:ok, attestingUserOrCompanyName} = Map.fetch(attestingCompanyDeatils, "name")
            {:ok, attestingUserOrCompanyLogoURL} = Map.fetch(attestingCompanyDeatils, "logo_url")
            {:ok, profileHeadlineType} = Map.fetch(attestedUserDetails, "profile_headline_type")
            
            if(profileHeadlineType == "null") do
                render(
                  conn,
                  "transactionDetailsAttestation.html",
                  transactionType: transactionType,
                  transactionHash: transactionHash,
                  attestedUserFullName: attestedUserFullName,
                  companyName: companyName,
                  attestedUserDesignation: attestedUserDesignation,
                  userHeadLineText: "",
                  userHeadLineCompany: "",
                  userHeadLineLocation: "",
                  attestedUserLogoURL: attestedUserLogoURL,
                  attestingUserOrCompanyName: attestingUserOrCompanyName,
                  attestingUserOrCompanyLogoURL: attestingUserOrCompanyLogoURL,
                  profileHeadlineType: profileHeadlineType,
                  exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
                  internal_transactions: internal_transactions,
                  block_height: Chain.block_height(),
                  show_token_transfers: Chain.transaction_has_token_transfers?(hash),
                  next_page_params: next_page_params(next_page, internal_transactions, params),
                  transaction: transaction,
                  logs: logs
                )
            end 

            {:ok, userHeadLineText} = Map.fetch(userHeadLine, "text")
            {:ok, userHeadLineLocation} = Map.fetch(userHeadLine, "location_name")
            {:ok, userHeadLineCompany} = Map.fetch(userHeadLine, "company")

      
            render(
                conn,
                "transactionDetailsAttestation.html",
                transactionType: transactionType,
                transactionHash: transactionHash,
                attestedUserFullName: attestedUserFullName,
                companyName: companyName,
                attestedUserDesignation: attestedUserDesignation,
                userHeadLineText: userHeadLineText,
                userHeadLineCompany: userHeadLineCompany,
                userHeadLineLocation: userHeadLineLocation,
                attestedUserLogoURL: attestedUserLogoURL,
                attestingUserOrCompanyName: attestingUserOrCompanyName,
                attestingUserOrCompanyLogoURL: attestingUserOrCompanyLogoURL,
                profileHeadlineType: profileHeadlineType,
                exchange_rate: Market.get_exchange_rate(Explorer.coin()) || Token.null(),
                internal_transactions: internal_transactions,
                block_height: Chain.block_height(),
                show_token_transfers: Chain.transaction_has_token_transfers?(hash),
                next_page_params: next_page_params(next_page, internal_transactions, params),
                transaction: transaction,
                logs: logs
            )
          end
  end
end
