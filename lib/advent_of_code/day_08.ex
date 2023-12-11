defmodule AdventOfCode.Day08 do
  def part1(input) do
    IO.puts("")
    IO.puts("")

    input
    |> parse_input()
    |> follow_directions({0, "AAA"}, fn current -> current == "AAA" end)
  end

  def follow_directions({directions, grid}, {current_steps, start}, finished?) do
    directions
    |> Enum.reduce({current_steps, start}, fn direction, {steps, current} ->
      if finished?.(current) do
        {steps, current}
      else
        grid
        |> Map.get(current)
        |> then(fn {l, r} -> if direction == :L, do: l, else: r end)
        |> then(fn new -> {steps + 1, new} end)
      end
    end)
    |> then(fn {steps, finish} ->
      if finished?.(finish),
        do: steps,
        else: follow_directions({directions, grid}, {steps, finish}, finished?)
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
        ~r/^(?<s>\w{3})\s=\s\((?<l>\w{3}),\s(?<r>\w{3})\)/,
        l
      )
    end)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> then(fn l -> {Keyword.get(l, :s), Keyword.get(l, :l), Keyword.get(l, :r)} end)
  end

  def part2(input) do
    IO.puts("")
    IO.puts("")

    input
    |> parse_input()
    |> then(fn {d, g} -> {{d, g}, find_starts(g)} end)
    |> then(fn {{d, g}, starts} ->
      Enum.map(starts, fn start ->
        follow_directions({d, g}, {0, start}, fn <<_, _, l>> -> l == ?Z end)
      end)
    end)
    |> Enum.reduce(1, fn a, b -> abs(div(a * b, Integer.gcd(a, b))) end)
  end

  def find_starts(grid) do
    grid
    |> Map.keys()
    |> Enum.filter(fn coord -> String.at(coord, -1) == "A" end)
  end
end
