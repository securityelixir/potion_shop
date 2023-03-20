defmodule CarafeWeb.PotionView do
  use CarafeWeb, :view

  def print_cents(c) do
    c / 100
  end
end
