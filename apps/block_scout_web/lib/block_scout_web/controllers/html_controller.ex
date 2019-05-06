defmodule BlockScoutWeb.HtmlController do
    use BlockScoutWeb, :controller
    alias Phoenix.View
    alias BlockScoutWeb.Call
    alias BlockScoutWeb.Controllers
    


    def show(conn, %{"id" => id}) do

        
        # redirect(conn, to: Controllers.test_transaction_internal_transaction_path(conn, :index, %{"id" => id}))


    end

end