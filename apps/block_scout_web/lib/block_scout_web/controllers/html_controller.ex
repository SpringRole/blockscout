defmodule BlockScoutWeb.HtmlController do
    use BlockScoutWeb, :controller
    alias Phoenix.View
    alias BlockScoutWeb.Call

    


    def index(conn, _params) do

        response =  Call.api_call()
        payload = Jason.decode!(response)
        {:ok, data} = Map.fetch(payload, "data")   
        {:ok, workExResult} = Map.fetch(data, "workExResult")
        {:ok, workExDetails} = Map.fetch(workExResult, "workExDetails")
        {:ok, transaction} = Map.fetch(workExDetails, "transaction")
        {:ok, transaction_type} = Map.fetch(transaction, "transaction_type")
        {:ok, attestedUserDetails} = Map.fetch(workExResult, "attestedUserDetails")
        {:ok, attestedUserName} = Map.fetch(attestedUserDetails, "name")
        {:ok, userHeadLine} = Map.fetch(attestedUserDetails, "userHeadLine")
        {:ok, userHeadLineText} = Map.fetch(hd(userHeadLine), "text")
        {:ok, userHeadLineLocation} = Map.fetch(hd(userHeadLine), "location_name")
        {:ok, userHeadLineCompany} = Map.fetch(hd(userHeadLine), "company")
        {:ok, attestingUserDeatils} = Map.fetch(workExResult, "attestingUserDeatils")
        {:ok, attestingUserName} = Map.fetch(attestingUserDeatils, "name")
        {:ok, profileHeadlineType} = Map.fetch(attestedUserDetails, "profile_headline_type")
 

        render(
            conn,
            "transactionDetails.html",
            transaction_type: transaction_type,
            attestedUserName: attestedUserName,
            userHeadLineText: userHeadLineText,
            userHeadLineCompany: userHeadLineCompany,
            userHeadLineLocation: userHeadLineLocation,
            attestingUserName: attestingUserName,
            profileHeadlineType: profileHeadlineType
        )
    end

end