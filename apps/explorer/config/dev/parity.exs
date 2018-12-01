use Mix.Config

config :explorer,
  json_rpc_named_arguments: [
    transport: EthereumJSONRPC.HTTP,
    transport_options: [
      http: EthereumJSONRPC.HTTP.HTTPoison,
      url: System.get_env("ETHEREUM_JSONRPC_HTTP_URL") || "https://chain.springrole.com:443",
      method_to_url: [
        eth_call: System.get_env("ETHEREUM_JSONRPC_TRACE_URL") || "https://chain.springrole.com:443",
        eth_getBalance: System.get_env("ETHEREUM_JSONRPC_TRACE_URL") || "https://chain.springrole.com:443",
        trace_replayTransaction: System.get_env("ETHEREUM_JSONRPC_TRACE_URL") || "https://chain.springrole.com:443"
      ],
      http_options: [recv_timeout: 60_000, timeout: 60_000, hackney: [pool: :ethereum_jsonrpc]]
    ],
    variant: EthereumJSONRPC.Parity
  ],
  subscribe_named_arguments: [
    transport: EthereumJSONRPC.WebSocket,
    transport_options: [
      web_socket: EthereumJSONRPC.WebSocket.WebSocketClient,
      url: System.get_env("ETHEREUM_JSONRPC_WS_URL") || "ws://18.204.107.205:8546"
    ],
    variant: EthereumJSONRPC.Parity
  ]
