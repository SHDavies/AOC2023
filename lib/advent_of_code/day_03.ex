# Pushing the limits of "If it's stupid and it works, it isn't stupid"

defmodule AdventOfCode.Day03 do
  def part1(input) do
    rows =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim(&1))
      |> Enum.with_index()

    rows
    |> Enum.reduce(0, &process_row(&1, &2, rows))
  end

  def process_row({row, row_index}, total, rows) do
    case Regex.named_captures(~r/(?<offset>\D*)(?<num>\d+)/, row) do
      %{"num" => num, "offset" => offset_str} ->
        offset = String.length(offset_str)
        num_length = String.length(num)

        to_add =
          row
          |> String.split("", trim: true)
          |> Enum.with_index()
          |> Enum.slice(offset..(offset + num_length - 1))
          |> Enum.map(&find_neighbors(&1, row_index, rows))
          |> Enum.join()
          |> then(fn neighbors ->
            if Regex.match?(~r/[^\d.]/, neighbors) do
              String.to_integer(num)
            else
              0
            end
          end)

        row
        |> String.split_at(offset)
        |> then(fn {first, second} ->
          first <> String.duplicate(".", num_length) <> String.slice(second, num_length..-1)
        end)
        |> then(&process_row({&1, row_index}, total + to_add, rows))

      _ ->
        total
    end
  end

  def find_neighbors({_, idx}, row_idx, rows) do
    row_length =
      rows
      |> Enum.at(row_idx)
      |> then(fn {r, _} -> String.length(r) end)

    start = max(0, idx - 1)
    finish = min(idx + 1, row_length - 1)

    above =
      if row_idx > 0 do
        rows
        |> Enum.at(row_idx - 1)
        |> then(fn {row, _} -> row end)
        |> String.slice(start..finish)
      else
        ""
      end

    horizontals =
      rows
      |> Enum.at(row_idx)
      |> then(fn {row, _} -> row end)
      |> then(&(char_or_default(&1, idx - 1) <> char_or_default(&1, idx + 1)))

    below =
      if row_idx < length(rows) - 1 do
        rows
        |> Enum.at(row_idx + 1)
        |> then(fn {row, _} -> row end)
        |> String.slice(start..finish)
      else
        ""
      end

    above <> horizontals <> below
  end

  def char_or_default(str, idx) do
    case String.at(str, idx) do
      nil -> ""
      x -> x
    end
  end

  def part2(input) do
    rows =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim(&1))
      |> Enum.with_index()

    rows
    |> Enum.reduce(0, &process_row_2(&1, &2, rows))
  end

  def process_row_2({row, row_index}, total, rows) do
    row_list = String.split(row, "", trim: true)

    case Enum.find_index(row_list, fn x -> x == "*" end) do
      nil ->
        total

      idx ->
        total = total + process_gear(idx, row, row_index, rows)
        process_row_2({String.replace(row, "*", ".", global: false), row_index}, total, rows)
    end
  end

  def process_gear(idx, row, row_idx, rows) do
    row_length = String.length(row)

    start = max(0, idx - 1)
    finish = min(idx + 1, row_length - 1)

    above =
      if row_idx > 0 do
        rows
        |> Enum.at(row_idx - 1)
        |> then(fn {row, _} -> row end)
        |> then(&process_vertical_neighbor(&1, start, finish))
        |> Enum.map(&String.to_integer(&1))
      else
        []
      end

    below =
      if row_idx < length(rows) - 1 do
        rows
        |> Enum.at(row_idx + 1)
        |> then(fn {row, _} -> row end)
        |> then(&process_vertical_neighbor(&1, start, finish))
        |> Enum.map(&String.to_integer(&1))
      else
        []
      end

    left =
      row
      |> String.split("", trim: true)
      |> Enum.at(idx - 1)
      |> then(
        &case &1 do
          x when x != nil ->
            if Regex.match?(~r/\d/, x),
              do: [find_number(row, idx - 1, :left) |> String.to_integer()],
              else: []

          _ ->
            []
        end
      )

    right =
      row
      |> String.split("", trim: true)
      |> Enum.at(idx + 1)
      |> then(
        &case &1 do
          x when x != nil ->
            if Regex.match?(~r/\d/, x),
              do: [find_number(row, idx + 1, :right) |> String.to_integer()],
              else: []

          _ ->
            []
        end
      )

    all_nums = above ++ below ++ left ++ right

    case all_nums do
      [x, y] -> x * y
      _ -> 0
    end
  end

  def process_vertical_neighbor(row, start, finish) do
    is_digits? =
      row
      |> String.split("", trim: true)
      |> Enum.slice(start..finish)
      |> Enum.map(fn i -> Regex.match?(~r/\d/, i) end)

    case is_digits? do
      [_, true, _] ->
        [find_number(row, start + 1, :both)]

      [true, false, true] ->
        [find_number(row, start, :left), find_number(row, finish, :right)]

      [true, false, false] ->
        [find_number(row, start, :left)]

      [false, false, true] ->
        [find_number(row, finish, :right)]

      [false, false, false] ->
        []
    end
  end

  def find_number(row, idx, direction) do
    row_list =
      row
      |> String.split("", trim: true)

    case direction do
      :both ->
        start =
          Enum.at(row_list, idx)

        left =
          row_list
          |> Enum.at(idx - 1)
          |> then(
            &if &1 != nil and Regex.match?(~r/\d/, &1) do
              find_number(row, idx - 2, :left) <> Enum.at(row_list, idx - 1)
            else
              ""
            end
          )

        right =
          row_list
          |> Enum.at(idx + 1)
          |> then(
            &if &1 != nil and Regex.match?(~r/\d/, &1) do
              Enum.at(row_list, idx + 1) <> find_number(row, idx + 2, :right)
            else
              ""
            end
          )

        left <> start <> right

      :left ->
        row_list
        |> Enum.at(idx)
        |> then(
          &if &1 != nil and Regex.match?(~r/\d/, &1) do
            find_number(row, idx - 1, :left) <> Enum.at(row_list, idx)
          else
            ""
          end
        )
        |> then(fn n -> if String.length(n) > 0, do: n, else: "" end)

      :right ->
        row_list
        |> Enum.at(idx)
        |> then(
          &if &1 != nil and Regex.match?(~r/\d/, &1) do
            Enum.at(row_list, idx) <> find_number(row, idx + 1, :right)
          else
            ""
          end
        )
        |> then(fn n -> if String.length(n) > 0, do: n, else: "" end)
    end
  end
end
