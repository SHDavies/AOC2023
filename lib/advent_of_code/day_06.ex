defmodule AdventOfCode.Day06 do
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&get_ways/1)
    |> Enum.map(&length/1)
    |> Enum.reduce(fn x, acc -> x * acc end)
  end

  def get_ways({time, distance}) do
    for i <- 1..(time - 1), is_valid_way(i, time, distance), do: true
  end

  def is_valid_way(wait, time, distance) do
    wait * (time - wait) > distance
  end

  def parse_input(input) do
    %{"raw_times" => raw_times, "raw_distances" => raw_distances} =
      Regex.named_captures(~r/Time:(?<raw_times>.+)\n\s*Distance:(?<raw_distances>.+)/, input)

    {times, distances} = {parse_raw(raw_times), parse_raw(raw_distances)}

    List.zip([times, distances])
  end

  def parse_raw(raw) do
    raw
    |> String.split(" ", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end

  def part2(_args) do
  end
end
