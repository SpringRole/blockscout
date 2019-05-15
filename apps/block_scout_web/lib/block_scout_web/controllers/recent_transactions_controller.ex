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



#  transactions =
#         Enum.map(recent_transactions, fn transaction ->
#           %{
#             transaction_hash: Hash.to_string(transaction.hash),
#             transaction_html:
#               View.render_to_string(BlockScoutWeb.TransactionView, "_tile.html", transaction: transaction)
#           }
#         end)
    
      # recent_transactions = [
      #   %{
      #     hash: "0xdbd3b487ff78cfd19e9e4cf07037cc5712db578f211601145508dc04ada6395a"
      #   },
      #   %{
      #     hash: "0x27fd044c54399930235a6306b6bad0594d11f9a63363639533350de1fa670d51"
      #   },
      #   %{
      #     hash: "0xb43c75dfb59b011184240cca6ab0c05fcb5e4bdd7767d9d9a276c8379c4b1c56"
      #   },
      #   %{
      #     hash: "0x5832a91d505e7855851ec7df32a1687898261544669fc65bab1b6e0f34f20c07"
      #   },
      #   %{
      #     hash: "0x5d8834a62d9ae20f2e6e53194f171ec9e02e3ea288b1aa6d4ee694905fa75549"
      #   }

      # ]

        transactions = 
          Enum.map(recent_transactions, fn transaction -> 
            response = Call.single_transaction(transaction.hash)
            payload = Jason.decode!(response)
            {:ok, data} = Map.fetch(payload, "data")



            if(Map.has_key?(data, "workExResult")) do
              {:ok, workExResult} = Map.fetch(data, "workExResult")
    
              if(Map.has_key?(workExResult, "attestingUserDeatils")) do
                {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
                {:ok, company} = Map.fetch(workExDetails, "company")
                {:ok, companyName} = Map.fetch(company, "name")    
                {:ok, attestedUserDetails} = Map.fetch(workExResult, "attestedUserDetails")
                {:ok, attestedUserName} = Map.fetch(attestedUserDetails, "name")
                {:ok, attestedUserFullName} = Map.fetch(attestedUserName, "full") 
                {:ok, profileHeadlineType} = Map.fetch(attestedUserDetails, "profile_headline_type")  
                {:ok, attestedUserDesignation} = Map.fetch(attestedUserDetails, "designation")
                {:ok, attestingUserDeatils} = Map.fetch(workExResult, "attestingUserDeatils")
                {:ok, attestingUserOrCompanyName} = Map.fetch(attestingUserDeatils, "name") 
                {:ok, attestingUserOrCompanyFullName} = Map.fetch(attestingUserOrCompanyName, "full")   
                mapping = %{
                  transaction: transaction, 
                   data: data, 
                   workExResult: workExResult,
                    companyName: companyName,
                    attestedUserFullName: attestedUserFullName,
                    profileHeadlineType: profileHeadlineType,
                    attestedUserDesignation: attestedUserDesignation,
                    attestingUserOrCompanyFullName: attestingUserOrCompanyFullName
                }
                %{
                  transaction_hash: transaction.hash,
                  transaction_html:
                    View.render_to_string(BlockScoutWeb.TransactionView, "_tile.html", mapping: mapping)   
                }         
              end  
    
              if (Map.has_key?(workExResult, "attestingCompanyDeatils")) do
                {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
                {:ok, company} = Map.fetch(workExDetails, "company")
                {:ok, companyName} = Map.fetch(company, "company_name")
                {:ok, attestedUserDetails} = Map.fetch(workExResult, "attestedUserDetails")
                {:ok, attestedUserName} = Map.fetch(attestedUserDetails, "name")
                {:ok, attestedUserFullName} = Map.fetch(attestedUserName, "full")
                {:ok, profileHeadlineType} = Map.fetch(attestedUserDetails, "profile_headline_type")
                {:ok, attestedUserDesignation} = Map.fetch(attestedUserDetails, "designation")
                {:ok, attestingCompanyDeatils} = Map.fetch(workExResult, "attestingCompanyDeatils")
                {:ok, attestingUserOrCompanyName} = Map.fetch(attestingCompanyDeatils, "name") 
                {:ok, attestingUserOrCompanyFullName} = Map.fetch(attestingUserOrCompanyName, "full") 
                mapping = %{
                  transaction: transaction,  data: data,
                  workExResult: workExResult,
                  attestedUserFullName: attestedUserFullName,
                  profileHeadlineType: profileHeadlineType,
                  attestedUserDesignation: attestedUserDesignation,
                  attestingUserOrCompanyName: attestingUserOrCompanyName,
                  attestingUserOrCompanyFullName: attestingUserOrCompanyFullName
                }  
                %{
                  transaction_hash: transaction.hash,
                  transaction_html:
                    View.render_to_string(BlockScoutWeb.TransactionView, "_tile.html", mapping: mapping)

                }
                


              end
            end


            if (Map.has_key?(data, "VanityResult")) do
              {:ok, vanityResult} = Map.fetch(data, "VanityResult")
              {:ok, userName} = Map.fetch(vanityResult, "name")
              {:ok, userFullName} = Map.fetch(userName, "full")
              {:ok, userVanityURL} = Map.fetch(vanityResult, "vanity_url")
              mapping = %{
                transaction: transaction, data: data,
                    userFullName: userFullName,
                    userVanityURL: userVanityURL
              }
              %{
                transaction_hash: transaction.hash,
                transaction_html:
                    View.render_to_string(BlockScoutWeb.TransactionView, "_tile.html", mapping: mapping)
              }
            end



          end)
          


      json(conn, %{transactions: transactions})
    else
      _ -> unprocessable_entity(conn)
    end
  end
end





