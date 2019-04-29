defmodule BlockScoutWeb.HtmlController do
    use BlockScoutWeb, :controller
    alias Phoenix.View
    alias BlockScoutWeb.Call

    response = Call.api_call()


    def index(conn, _params) do
        render(
            conn,
            "test_transaction.html",
            current_path: current_path(conn),
            response: response
        )
    end

end