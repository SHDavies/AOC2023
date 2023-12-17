defmodule AdventOfCode.Day14 do
  def part1(input) do
    input
    |> parse()
    |> Enum.map(&roll_north_dumb/1)
    |> Enum.map(&calculate_score/1)
    |> Enum.sum()
  end

  def part2(input) do
    {rocks, max_row, max_col} =
      input
      |> parse_better()

    {loop_start, loop_length, seq} = cycle({rocks, max_row, max_col})

    seq
    |> Enum.at(loop_start + rem(1_000_000_000 * 4 - loop_start, loop_length) - 1)
    |> calculate_better(max_row)
  end

  def calculate_better(rocks, max_row) do
    rocks
    |> Enum.reduce(0, fn {row, _}, acc -> acc + max_row - row - 1 end)
  end

  def cycle({rocks, max_row, max_col}) do
    {rolling, fixed} = Enum.split_with(rocks, fn {c, _, _} -> c == "O" end)
    rolling = rolling |> Enum.map(fn {_, row, col} -> {row, col} end)
    fixed = fixed |> Enum.map(fn {_, row, col} -> {row, col} end)

    [
      {fn {l_row, _}, {r_row, _} -> l_row <= r_row end, fn {r, c} -> {r - 1, c} end},
      {fn {_, l_col}, {_, r_col} -> l_col <= r_col end, fn {r, c} -> {r, c - 1} end},
      {fn {l_row, _}, {r_row, _} -> l_row >= r_row end, fn {r, c} -> {r + 1, c} end},
      {fn {_, l_col}, {_, r_col} -> l_col >= r_col end, fn {r, c} -> {r, c + 1} end}
    ]
    |> Stream.cycle()
    |> Stream.with_index()
    |> Enum.reduce_while([rolling], fn {{sort, move}, idx}, acc ->
      result =
        acc
        |> List.last()
        |> roll(fixed, max_row, max_col, sort, move)
        |> IO.inspect(label: "result")

      found = Enum.find_index(acc, &(result == &1))

      if found != nil do
        {:halt, {found, idx - found, acc}}
      else
        {:cont, acc ++ [result]}
      end
    end)
  end

  def roll(rolling, fixed, max_row, max_col, sort, move) do
    rolling
    |> IO.inspect(label: "rolling")
    |> Enum.sort(sort)
    |> IO.inspect(label: "sorted")
    |> Enum.reduce([], fn coords, acc ->
      [roll_step(coords, move, acc, fixed, max_row, max_col) | acc]
    end)
  end

  def roll_step(coords, move, acc, fixed, max_row, max_col) do
    IO.inspect({coords, move, acc, fixed, max_row, max_col}, label: "roll_step")
    new_pos = move.(coords) |> IO.inspect(label: "new_pos")
    {row, col} = new_pos

    if new_pos in acc or new_pos in fixed or row > max_row or col > max_col or row < 0 or col < 0 do
      coords
    else
      roll_step(new_pos, move, acc, fixed, max_row, max_col)
    end
  end

  def parse_better(input) do
    rocks =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, row_idx} ->
        row
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reject(&(elem(&1, 0) == "."))
        |> Enum.map(fn {c, col_idx} -> {c, row_idx, col_idx} end)
      end)

    max_row = rocks |> Enum.max_by(fn {_, r, _} -> r end) |> elem(1)
    max_col = rocks |> Enum.max_by(fn {_, _, c} -> c end) |> elem(2)

    {rocks, max_row, max_col}
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
    |> then(fn rows ->
      0..(length(Enum.at(rows, 0)) - 1)
      |> Enum.map(fn idx -> Enum.map(rows, fn row -> Enum.at(row, idx) end) end)
    end)
  end

  def roll_north_dumb(row) do
    row
    |> Enum.with_index()
    |> Enum.reduce(row, fn {cell, idx}, acc ->
      cond do
        idx == 0 ->
          acc

        cell == "O" ->
          new_idx = find_roll_target(acc, idx)

          if new_idx != idx do
            acc
            |> List.replace_at(new_idx, "O")
            |> List.replace_at(idx, ".")
          else
            acc
          end

        true ->
          acc
      end
    end)
  end

  def find_roll_target(row, idx) do
    row
    |> Enum.with_index()
    |> Enum.slice(0..(idx - 1))
    |> Enum.reverse()
    |> Enum.find(fn {cell, _} -> cell != "." end)
    |> then(fn result ->
      case result do
        {_, open_idx} -> open_idx + 1
        nil -> 0
      end
    end)
  end

  def calculate_score(row) do
    l = length(row)

    row
    |> Enum.with_index()
    |> Enum.reduce(0, fn {cell, idx}, acc -> if cell == "O", do: acc + l - idx, else: acc end)
  end
end
