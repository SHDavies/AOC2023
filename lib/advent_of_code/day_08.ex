defmodule AdventOfCode.Day08 do
  def part1(input) do
    IO.puts("")
    IO.puts("")

    input
    |> parse_input()
    |> follow_directions({0, :AAA})
  end

  def follow_directions({directions, grid}, {current_steps, start}) do
    directions
    |> Enum.reduce({current_steps, start}, fn direction, {steps, current} ->
      case current do
        :ZZZ ->
          {steps, current}

        _ ->
          grid
          |> Map.get(current)
          |> then(fn {l, r} -> if direction == :L, do: l, else: r end)
          |> then(fn new -> {steps + 1, new} end)
      end
    end)
    |> then(fn {steps, finish} ->
      if finish == :ZZZ, do: steps, else: follow_directions({directions, grid}, {steps, finish})
    end)
  end

  def parse_input(input) do
    lines =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)

    {directions, grid} =
      lines
      |> List.pop_at(0)
      |> then(fn {d, g} ->
        {
          String.split(d, "", trim: true) |> Enum.map(&String.to_atom/1),
          Enum.map(g, &parse_grid_line/1)
        }
      end)

    grid
    |> Enum.reduce(%{}, fn {s, l, r}, acc -> Map.put(acc, s, {l, r}) end)
    |> then(fn g -> {directions, g} end)
  end

  def parse_grid_line(line) do
    line
    |> then(fn l ->
      Regex.named_captures(
        ~r/^(?<s>[A-Z]{3})\s=\s\((?<l>[A-Z]{3}),\s(?<r>[A-Z]{3})\)/,
        l
      )
    end)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), String.to_atom(v)} end)
    |> then(fn l -> {Keyword.get(l, :s), Keyword.get(l, :l), Keyword.get(l, :r)} end)
  end

  def part2(_args) do
  end
end
