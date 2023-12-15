defmodule AdventOfCode.Day11 do
  def part1(input) do
    input
    |> parse_input()
    |> expand(1)
    |> find_paths()
  end

  def expand({stars, missing_rows, missing_cols}, size) do
    stars
    |> Enum.map(fn {row, col} ->
      expand_rows = Enum.filter(missing_rows, &(&1 < row)) |> length()
      expand_cols = Enum.filter(missing_cols, &(&1 < col)) |> length()

      {row + expand_rows * size, col + expand_cols * size}
    end)
  end

  def find_paths([_star | []]), do: 0

  def find_paths([star | stars]) do
    stars
    |> Enum.map(fn dest -> distance(star, dest) end)
    |> Enum.sum()
    |> then(fn count -> count + find_paths(stars) end)
  end

  def distance({lx, ly}, {rx, ry}), do: abs(lx - rx) + abs(ly - ry)

  def parse_input(input) do
    rows =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn row -> String.split(row, "", trim: true) end)

    height = length(rows)
    width = rows |> Enum.at(0) |> length()

    stars =
      rows
      |> Enum.with_index()
      |> Enum.reduce([], fn {row, row_idx}, acc ->
        row
        |> Enum.with_index()
        |> Enum.filter(fn {item, _} -> item == "#" end)
        |> Enum.map(fn {_, item_idx} -> {row_idx, item_idx} end)
        |> then(fn items -> acc ++ items end)
      end)

    missing_rows =
      stars
      |> Enum.map(fn {row, _} -> row end)
      |> MapSet.new()
      |> then(fn set ->
        0..(height - 1)
        |> MapSet.new()
        |> MapSet.difference(set)
      end)

    missing_cols =
      stars
      |> Enum.map(fn {_, col} -> col end)
      |> MapSet.new()
      |> then(fn set ->
        0..(width - 1)
        |> MapSet.new()
        |> MapSet.difference(set)
      end)

    {stars, missing_rows, missing_cols}
  end

  def part2(input) do
    input
    |> parse_input()
    |> expand(999_999)
    |> find_paths()
  end
end
