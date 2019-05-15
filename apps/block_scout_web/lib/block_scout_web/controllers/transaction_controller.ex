defmodule BlockScoutWeb.TransactionController do
  use BlockScoutWeb, :controller

  import BlockScoutWeb.Chain, only: [paging_options: 1, next_page_params: 3, split_list_by_page: 1]

  alias BlockScoutWeb.TransactionView
  alias Explorer.Chain
  alias Phoenix.View
  alias BlockScoutWeb.Call

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



      # Enum.map(transactions, fn transaction -> 
        
      #   response =  Call.single_transaction(transaction.hash)
      #   payload = Jason.decode!(response)
      #   {:ok, data} = Map.fetch(payload, "data")

      #   if(Map.has_key?(data, "workExResult")) do
      #     {:ok, workExResult} = Map.fetch(data, "workExResult")

      #     if(Map.has_key?(workExResult, "attestingUserDeatils")) do
      #       {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
      #       {:ok, company} = Map.fetch(workExDetails, "company")
      #       {:ok, companyName} = Map.fetch(company, "name")    
      #       {:ok, attestedUserDetails} = Map.fetch(workExResult, "attestedUserDetails")
      #       {:ok, attestedUserName} = Map.fetch(attestedUserDetails, "name")
      #       {:ok, attestedUserFullName} = Map.fetch(attestedUserName, "full")   
      #       {:ok, attestedUserDesignation} = Map.fetch(attestedUserDetails, "designation")
      #       {:ok, attestingUserDeatils} = Map.fetch(workExResult, "attestingUserDeatils")
      #       {:ok, attestingUserOrCompanyName} = Map.fetch(attestingUserDeatils, "name") 
      #       {:ok, attestingUserOrCompanyFullName} = Map.fetch(attestingUserOrCompanyName, "full") 
            
      #       render(
      #         conn,
      #         "_tile.html",
      #         data: data,
      #         workExResult: workExResult,
      #         transaction: transaction,
      #         # next_page_path: next_page_path,
      #         companyName: companyName,
      #         attestedUserFullName: attestedUserFullName,
      #         attestedUserDesignation: attestedUserDesignation,
      #         attestingUserOrCompanyFullName: attestingUserOrCompanyFullName,          
      #       )

      #     end  

      #     if(Map.has_key?(workExResult, "attestingCompanyDeatils")) do
      #       {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
      #       {:ok, company} = Map.fetch(workExDetails, "company")
      #       {:ok, companyName} = Map.fetch(company, "company_name")
      #       {:ok, attestedUserDetails} = Map.fetch(workExResult, "attestedUserDetails")
      #       {:ok, profileHeadlineType} = Map.fetch(attestedUserDetails, "profile_headline_type")
      #       {:ok, attestedUserDesignation} = Map.fetch(attestedUserDetails, "designation")
      #       {:ok, attestingCompanyDeatils} = Map.fetch(workExResult, "attestingCompanyDeatils")
      #       {:ok, attestingUserOrCompanyName} = Map.fetch(attestingCompanyDeatils, "name")

      #       render(
      #         conn,
      #         "_tile.html",
      #         data: data,
      #         workExResult: workExResult,
      #         companyName: companyName,
      #         profileHeadlineType: profileHeadlineType,
      #         attestedUserDesignation: attestedUserDesignation,
      #         attestingUserOrCompanyName: attestingUserOrCompanyName
      #       )


      #     end
      #   end
        
      #   if(Map.has_key?(data, "VanityResult")) do
      #     {:ok, vanityResult} = Map.fetch(data, "VanityResult")
      #     {:ok, userName} = Map.fetch(vanityResult, "name")
      #     {:ok, userFullName} = Map.fetch(userName, "full")
      #     {:ok, userVanityURL} = Map.fetch(vanityResult, "vanity_url")

      #     render(
      #       conn,
      #       "_tile.html",
      #       data: data,
      #       userFullName: userFullName,
      #       userVanityURL: userVanityURL
      #     )
      #   end  
      # end)


              json(
                conn,
                %{
                  items:
                    Enum.map(transactions, fn transaction ->         
                      View.render_to_string(
                        TransactionView,
                        "_tile.html",
                        transaction: transaction
                      )
                    end),
                  next_page_path: next_page_path
                }
              )
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
