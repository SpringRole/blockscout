defmodule BlockScoutWeb.ChainView do
  use BlockScoutWeb, :view

  alias BlockScoutWeb.LayoutView
  alias Explorer.Chain
  alias Explorer.Chain.Block.Reward
  alias Explorer.Chain.{Address, Block, InternalTransaction, Transaction, Wei}

  def block_timestamp(%Transaction{block_number: nil, inserted_at: time}), do: time
  def block_timestamp(%Transaction{block: %Block{timestamp: time}}), do: time

end
