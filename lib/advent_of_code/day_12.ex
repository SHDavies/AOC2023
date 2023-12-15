defmodule AdventOfCode.Day12 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&combos/1)
    |> Enum.sum()
  end

  def combos({str, groups}), do: combos(str, false, groups)

  def combos(<<>>, ctr, []) when ctr == 0 or ctr == false, do: 1
  def combos(<<>>, _, _), do: 0

  def combos(<<".", rem::binary>>, 0, groups), do: combos(rem, false, groups)
  def combos(<<".", rem::binary>>, false, groups), do: combos(rem, false, groups)
  def combos(<<".", _::binary>>, _, _), do: 0

  def combos(<<"#", _::binary>>, false, []), do: 0
  def combos(<<"#", _::binary>>, 0, _), do: 0
  def combos(<<"#", rem::binary>>, false, [h | t]), do: combos(rem, h - 1, t)
  def combos(<<"#", rem::binary>>, n, groups), do: combos(rem, n - 1, groups)

  def combos(<<"?", rem::binary>>, ctr, groups) do
    memoized_combos("." <> rem, ctr, groups) + memoized_combos("#" <> rem, ctr, groups)
  end

  def memoized_combos(str, ctr, groups) do
    if v = Process.get({str, ctr, groups}) do
      v
    else
      v = combos(str, ctr, groups)
      Process.put({str, ctr, groups}, v)
      v
    end
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn row ->
      row
      |> String.split(" ", trim: true)
      |> then(fn [template, counts] ->
        {template, parse_counts(counts)}
      end)
    end)
  end

  def parse_counts(counts) do
    String.split(counts, ",", trim: true) |> Enum.map(&String.to_integer/1)
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&expand/1)
    |> Enum.map(&combos/1)
    |> Enum.sum()
  end

  def expand({str, groups}) do
    {
      str |> List.duplicate(5) |> Enum.intersperse("?") |> Enum.join(),
      groups |> List.duplicate(5) |> List.flatten()
    }
  end
end
