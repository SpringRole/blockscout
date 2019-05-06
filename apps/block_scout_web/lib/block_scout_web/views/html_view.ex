defmodule BlockScoutWeb.HtmlView do
    use BlockScoutWeb, :view

    alias BlockScoutWeb.Call
    def test() do
        Call.api_call()
    end
   
end