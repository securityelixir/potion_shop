defmodule Carafe.Vendors do
  def get_vendors do
    File.read!("./priv/static/vendors.txt")
    |> String.split("\n")
    |> Enum.map(fn x ->
      [name, year, country] = String.split(x, ",")

      %{
        name: name,
        year: year,
        country: country
      }
    end)
  end
end
