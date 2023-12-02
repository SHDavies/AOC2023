defmodule AdventOfCode.Day02 do
  def part1({input, requirement}) do
    IO.puts("")

    input
    |> find_maxes
    |> Enum.filter(fn %{blue: blue, green: green, red: red} ->
      blue <= requirement.blue and green <= requirement.green and red <= requirement.red
    end)
    |> Enum.map(fn %{id: id} -> String.to_integer(id) end)
    |> Enum.sum
  end

  def part2(input) do
    IO.puts("")

    input
    |> find_maxes
    |> Enum.map(fn %{blue: blue, green: green, red: red} -> blue * green * red end)
    |> Enum.sum
  end

  def find_maxes(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      %{"id" => id} = Regex.named_captures(~r/Game (?<id>\d+):/, line)

      grabs = String.split(line, "; ")

      blue_max =
        grabs
        |> Enum.filter(fn grab -> Regex.match?(~r/\d+ blue/, grab) end)
        |> Enum.map(fn grab -> Regex.named_captures(~r/(?<blue>\d+) blue/, grab) end)
        |> Enum.map(fn %{"blue" => n} -> String.to_integer(n) end)
        |> Enum.max

      green_max =
        grabs
        |> Enum.filter(fn grab -> Regex.match?(~r/\d+ green/, grab) end)
        |> Enum.map(fn grab -> Regex.named_captures(~r/(?<green>\d+) green/, grab) end)
        |> Enum.map(fn %{"green" => n} -> String.to_integer(n) end)
        |> Enum.max

      red_max =
        grabs
        |> Enum.filter(fn grab -> Regex.match?(~r/\d+ red/, grab) end)
        |> Enum.map(fn grab -> Regex.named_captures(~r/(?<red>\d+) red/, grab) end)
        |> Enum.map(fn %{"red" => n} -> String.to_integer(n) end)
        |> Enum.max

      %{id: id, blue: blue_max, green: green_max, red: red_max}
    end)
  end
end
