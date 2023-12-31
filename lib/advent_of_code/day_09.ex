defmodule AdventOfCode.Day09 do
  def part1(input) do
    IO.puts("")
    IO.puts("")

    input
    |> parse_input()
    |> Enum.map(fn row -> find_next(row, [], &finish_sequence_forward/2) end)
    |> Enum.sum()
  end

  def find_next(sequence, previous, finish) do
    if Enum.all?(sequence, &(&1 == 0)) do
      finish.(previous, 0)
    else
      sequence
      |> make_next_row()
      |> then(fn row -> find_next(row, [sequence | previous], finish) end)
    end
  end

  def make_next_row(sequence) do
    sequence
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [l, r] -> r - l end)
  end

  def finish_sequence_forward([current | rest], to_add) do
    if Enum.empty?(rest) do
      current
      |> Enum.at(-1)
      |> then(fn x -> x + to_add end)
    else
      current
      |> Enum.at(-1)
      |> then(fn x -> x + to_add end)
      |> then(fn x -> finish_sequence_forward(rest, x) end)
    end
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      row
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def part2(input) do
    IO.puts("")
    IO.puts("")

    input
    |> parse_input()
    |> Enum.map(fn row -> find_next(row, [], &finish_sequence_backward/2) end)
    |> Enum.sum()
  end

  @spec finish_sequence_backward(nonempty_maybe_improper_list(), any()) :: any()
  def finish_sequence_backward([current | rest], to_subtract) do
    if Enum.empty?(rest) do
      current
      |> Enum.at(0)
      |> then(fn x -> x - to_subtract end)
    else
      current
      |> Enum.at(0)
      |> then(fn x -> x - to_subtract end)
      |> then(fn x -> finish_sequence_backward(rest, x) end)
    end
  end
end
