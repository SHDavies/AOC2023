defmodule AdventOfCode.Day15 do
  def part1(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&get_op/1)
    |> Enum.reduce(%{}, &set_lenses/2)
    |> Enum.map(&get_focus_power/1)
    |> Enum.sum()
  end

  def hash(input) do
    input
    |> String.graphemes()
    |> Enum.reduce(0, fn <<c>>, acc -> rem((acc + c) * 17, 256) end)
  end

  def get_op(input) do
    if String.contains?(input, "-") do
      label =
        input
        |> String.slice(0..-2)

      box = hash(label)

      {:remove, box, label}
    else
      [label, pos] = String.split(input, "=")

      box = hash(label)

      {:put, box, label, String.to_integer(pos)}
    end
  end

  def set_lenses(op, boxes) do
    case op do
      {:remove, box, label} ->
        boxes
        |> Map.update(box, Keyword.new(), fn lenses ->
          Keyword.delete(lenses, String.to_atom(label))
        end)

      {:put, box, label, pos} ->
        label = String.to_atom(label)

        boxes
        |> Map.update(box, Keyword.new([{label, pos}]), fn lenses ->
          if Keyword.has_key?(lenses, label) do
            Keyword.replace(lenses, label, pos)
          else
            lenses ++ [{label, pos}]
          end
        end)
    end
  end

  def get_focus_power({box, lenses}) do
    lenses
    |> Enum.with_index()
    |> Enum.map(fn {{_label, focal_length}, pos} -> (1 + box) * (1 + pos) * focal_length end)
    |> Enum.sum()
  end
end
