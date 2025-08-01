# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Carafe.Repo.insert!(%Carafe.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Carafe.Potions

user = %{
  "email" => "jack@potion.shop",
  "password" => "Abcd123456789tyuiop"
}

Carafe.Accounts.register_user(user)

potions = [
  %{
    "name" => "Strength",
    "milliliters" => 50,
    "price" => 499,
    "secret" => false
  },
  %{
    "name" => "Feather",
    "milliliters" => 10,
    "price" => 899,
    "secret" => false
  },
  %{
    "name" => "Jump",
    "milliliters" => 25,
    "price" => 299,
    "secret" => false
  },
  %{
    "name" => "Levitate",
    "milliliters" => 40,
    "price" => 2999,
    "secret" => false
  },
  %{
    "name" => "Cure Poison",
    "milliliters" => 10,
    "price" => 3999,
    "secret" => false
  },
  %{
    "name" => "Resist Fire",
    "milliliters" => 7,
    "price" => 299,
    "secret" => false
  },
  %{
    "name" => "Restore Health",
    "milliliters" => 80,
    "price" => 4999,
    "secret" => false
  },
  %{
    "name" => "Fire",
    "milliliters" => 10,
    "price" => 9999,
    "secret" => true
  },
  %{
    "name" => "Shield",
    "milliliters" => 40,
    "price" => 899,
    "secret" => true
  },
  %{
    "name" => "Swim",
    "milliliters" => 20,
    "price" => 399,
    "secret" => true
  },
  %{
    "name" => "Water Walk",
    "milliliters" => 5,
    "price" => 8999,
    "secret" => true
  },
  %{
    "name" => "Light",
    "milliliters" => 50,
    "price" => 599,
    "secret" => true
  }
]

reviews = [
  %{
    "body" => "Did not work.",
    "score" => "1",
    "potion_id" => "1"
  },
  %{
    "body" => "Highly effective, great buy.",
    "score" => "5",
    "potion_id" => "2"
  },
  %{
    "body" => "Did not work.",
    "score" => "1",
    "potion_id" => "3"
  },
  %{
    "body" => "Highly effective, great buy.",
    "score" => "5",
    "potion_id" => "4"
  },
  %{
    "body" => "Did not work.",
    "score" => "1",
    "potion_id" => "5"
  },
  %{
    "body" => "Highly effective, great buy.",
    "score" => "5",
    "potion_id" => "6"
  },
  %{
    "body" => "Did not work.",
    "score" => "1",
    "potion_id" => "7"
  },
  %{
    "body" => "Highly effective, great buy.",
    "score" => "5",
    "potion_id" => "8"
  },
  %{
    "body" => "Did not work.",
    "score" => "1",
    "potion_id" => "9"
  }
]

Enum.each(potions, fn p ->
  Potions.create_potion(p)
end)

Enum.each(reviews, fn r ->
  Potions.create_review(1, r)
end)
