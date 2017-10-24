defmodule Packex.Package do
  @enforce_keys [:name, :description, :products]
  defstruct id: nil, name: nil, description: nil, products: nil, price: 0
end

