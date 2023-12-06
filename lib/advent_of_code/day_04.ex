defmodule AdventOfCode.Day04 do
  def part1(input) do
    IO.puts("")

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Regex.named_captures(~r/^\s*Card\s+\d+:(?<winning>.+)\|(?<game_card>.+)$/, &1))
    |> Enum.map(fn %{"winning" => winning_str, "game_card" => game_card_str} ->
      winning =
        winning_str
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      game_card =
        game_card_str
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      {winning, game_card}
    end)
    |> Enum.map(&process_game/1)
    |> Enum.sum()
  end

  def process_game({winning, game}) do
    game
    |> Enum.filter(fn x -> Enum.member?(winning, x) end)
    |> length()
  end

  def part2(input) do
    IO.puts("")

    input
    |> String.split("\n", trim: true)
    |> Enum.map(
      &Regex.named_captures(
        ~r/^\s*Card\s+(?<card_number>\d+):(?<winning>.+)\|(?<game_card>.+)$/,
        &1
      )
    )
    |> Enum.map(fn %{
                     "card_number" => card,
                     "winning" => winning_str,
                     "game_card" => game_card_str
                   } ->
      winning =
        winning_str
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      game_card =
        game_card_str
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      {String.to_integer(card), winning, game_card}
    end)
    |> Enum.reduce(%{}, fn {card, winning, game}, acc ->
      Map.put(acc, card, {winning, game, 1})
    end)
    |> then(fn x -> process_game_2(x, 1) end)
    |> Enum.map(fn {_, {_, _, c}} -> c end)
    |> Enum.sum()
  end

  def process_game_2(map, card_number) do
    case Map.get(map, card_number) do
      {winning, game, count} ->
        matches = process_game({winning, game})

        if matches > 0 do
          Enum.reduce((card_number + 1)..(card_number + matches), map, fn i, m ->
            Map.update(m, i, nil, fn {w, g, c} ->
              {w, g, c + count}
            end)
          end)
          |> process_game_2(card_number + 1)
        else
          process_game_2(map, card_number + 1)
        end

      nil ->
        map
    end
  end
end
