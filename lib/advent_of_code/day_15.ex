defmodule AdventOfCode.Day15 do
  def part1(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def part2(_args) do
  end

  def hash(input) do
    input
    |> String.graphemes()
    |> Enum.reduce(0, fn <<c>>, acc -> rem((acc + c) * 17, 256) end)
  end
end
