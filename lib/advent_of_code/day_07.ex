defmodule AdventOfCode.Day07 do
  # type atom doesn't do anything but helps with debugging
  @hands %{
    "11111" => {:high_card, 1},
    "1112" => {:pair, 2},
    "122" => {:two_pair, 3},
    "113" => {:three_of_a_kind, 4},
    "23" => {:full_house, 5},
    "14" => {:four_of_a_kind, 6},
    "5" => {:five_of_a_kind, 7}
  }

  @cards %{
    "2" => 0,
    "3" => 1,
    "4" => 2,
    "5" => 3,
    "6" => 4,
    "7" => 5,
    "8" => 6,
    "9" => 7,
    "T" => 8,
    "J" => 9,
    "Q" => 10,
    "K" => 11,
    "A" => 12
  }

  @cards_with_jokers %{
    "J" => 0,
    "2" => 1,
    "3" => 2,
    "4" => 3,
    "5" => 4,
    "6" => 5,
    "7" => 6,
    "8" => 7,
    "9" => 8,
    "T" => 9,
    "Q" => 10,
    "K" => 11,
    "A" => 12
  }

  def part1(input) do
    IO.puts("")
    IO.puts("")

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [hand, bet] -> {hand, String.to_integer(bet)} end)
    |> Enum.map(fn {hand, bet} -> {determine_hand(hand), bet} end)
    |> Enum.sort(fn {h1, _}, {h2, _} -> sort_cards(h1, h2, @cards) end)
    |> Enum.with_index()
    |> Enum.map(fn {{_, bet}, idx} -> bet * (idx + 1) end)
    |> Enum.sum()
  end

  def determine_hand(hand) do
    hand
    |> String.split("", trim: true)
    |> Enum.reduce(%{}, fn card, acc ->
      Map.update(acc, card, 1, fn prev -> prev + 1 end)
    end)
    |> Enum.to_list()
    |> Enum.sort_by(fn {_, count} -> count end)
    |> Enum.map(fn {_, count} -> count end)
    |> Enum.join()
    |> then(&@hands[&1])
    |> then(fn {type, val} -> {hand, type, val} end)
  end

  def sort_cards({h1_cards, _h1_type, h1_val}, {h2_cards, _h2_type, h2_val}, ranking) do
    if h1_val != h2_val do
      h1_val < h2_val
    else
      compare_cards(h1_cards, h2_cards, ranking, 0)
    end
  end

  def compare_cards(h1, h2, ranking, idx) do
    h1_val =
      h1
      |> String.at(idx)
      |> then(&ranking[&1])

    h2_val =
      h2
      |> String.at(idx)
      |> then(&ranking[&1])

    cond do
      h1_val != h2_val -> h1_val < h2_val
      idx < 4 -> compare_cards(h1, h2, ranking, idx + 1)
      true -> throw("Maxxed out")
    end
  end

  def determine_hand_with_jokers(hand) do
    sorted =
      hand
      |> String.split("", trim: true)
      |> Enum.reduce(%{}, fn card, acc ->
        Map.update(acc, card, 1, fn prev -> prev + 1 end)
      end)
      |> Enum.to_list()
      |> Enum.sort_by(fn {card, count} -> {count, @cards[card]} end)

    {j_cards, sorted} =
      sorted
      |> Enum.find_index(fn {card, _} -> card == "J" end)
      |> then(&if &1 != nil, do: List.pop_at(sorted, &1), else: {nil, sorted})

    if j_cards != nil do
      sorted
      |> Enum.at(-1)
      |> then(fn c ->
        case c do
          {card, _} -> String.replace(hand, "J", card)
          nil -> "AAAAA"
        end
      end)
      |> determine_hand()
      |> then(fn {_, type, val} -> {hand, type, val} end)
    else
      determine_hand(hand)
    end
  end

  def part2(input) do
    IO.puts("")
    IO.puts("")

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [hand, bet] -> {hand, String.to_integer(bet)} end)
    |> Enum.map(fn {hand, bet} -> {determine_hand_with_jokers(hand), bet} end)
    |> Enum.sort(fn {h1, _}, {h2, _} -> sort_cards(h1, h2, @cards_with_jokers) end)
    |> Enum.with_index()
    |> Enum.map(fn {{_, bet}, idx} -> bet * (idx + 1) end)
    |> Enum.sum()
  end
end
