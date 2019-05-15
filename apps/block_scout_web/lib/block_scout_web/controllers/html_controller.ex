defmodule BlockScoutWeb.HtmlController do
    use BlockScoutWeb, :controller
    alias Phoenix.View
   
    alias Explorer.Chain
    alias Explorer.Stats
    


    def show(conn, _params) do

        
       render(
           conn,
           "index.html",
           attestation_count: Stats.attestation_count() ,
           vanity_count: Stats.vanity_count(),
           transaction_time: Stats.transaction_time(),
           transaction_estimated_count: Chain.transaction_estimated_count(),
           transactions_path: recent_transactions_path(conn, :index)
       )

    # render(
    #         conn,
    #         "transactionDetails.html",
    #         current_path: current_path(conn),
    #     )


    end

end