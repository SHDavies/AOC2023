defmodule AdventOfCode.Day13 do
  @opposite %{
    "#" => ".",
    "." => "#"
  }

  def part1(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn grid ->
      grid
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(fn row -> row |> String.trim() |> String.split("", trim: true) end)
    end)
    |> Enum.map(&find_and_score_symmetry/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn grid ->
      grid
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(fn row -> row |> String.trim() |> String.split("", trim: true) end)
    end)
    |> Enum.map(&find_and_score_smudge/1)
    |> Enum.sum()
  end

  def find_and_score_smudge(grid) do
    case find_smudge_vertical(grid, {0, 0}) do
      x when x != nil ->
        x

      _ ->
        grid
        |> rotate_grid()
        |> find_smudge_vertical({0, 0})
        |> then(fn x -> x * 100 end)
    end
  end

  def find_smudge_vertical(grid, {row, col}) do
    case Enum.at(grid, row) do
      r when r != nil ->
        if length(r) > col do
          check_for_smudge(grid, {row, col})
        else
          find_smudge_vertical(grid, {row + 1, 0})
        end

      nil ->
        nil
    end
  end

  def check_for_smudge(grid, {row, col}, opposite \\ 1) do
    l =
      grid
      |> Enum.at(row)
      |> Enum.at(col)

    r =
      grid
      |> Enum.at(row)
      |> Enum.at(col + opposite)

    if r != nil do
      result =
        if(l != r) do
          axis =
            ((col + opposite + col) / 2) |> Float.ceil() |> trunc()

          if Enum.all?(grid, fn test_row -> is_symmetrical?(test_row, axis) end) do
            nil
          else
            updated =
              grid
              |> List.update_at(row, fn r -> List.update_at(r, col, fn i -> @opposite[i] end) end)

            if Enum.all?(updated, fn test_row -> is_symmetrical?(test_row, axis) end) do
              axis
            else
              nil
            end
          end
        else
          nil
        end

      if result != nil do
        result
      else
        check_for_smudge(grid, {row, col}, opposite + 2)
      end
    else
      find_smudge_vertical(grid, {row, col + 1})
    end
  end

  def find_and_score_symmetry(grid) do
    case find_vertical_symmetry(grid) do
      x when x != nil ->
        x

      _ ->
        find_horizontal_symmetry(grid)
    end
  end

  def rotate_grid(grid) do
    len = grid |> Enum.at(0) |> length()

    for idx <- 0..(len - 1) do
      grid
      |> Enum.map(fn row -> Enum.at(row, idx) end)
    end
    |> Enum.reverse()
  end

  def find_horizontal_symmetry(grid) do
    grid
    |> rotate_grid()
    |> find_vertical_symmetry()
    |> then(fn v -> v * 100 end)
  end

  def find_vertical_symmetry([hd | tl] = full), do: find_vertical_symmetry(hd, 1, tl, full)

  def find_vertical_symmetry(row, idx, [], [r1 | rem] = full) do
    case is_symmetrical?(row, idx) do
      true ->
        idx

      false ->
        find_vertical_symmetry(r1, idx + 1, rem, full)

      :end ->
        nil
    end
  end

  def find_vertical_symmetry(row, idx, [hd | tl], [r1 | rem] = full) do
    case is_symmetrical?(row, idx) do
      true ->
        find_vertical_symmetry(hd, idx, tl, full)

      false ->
        find_vertical_symmetry(r1, idx + 1, rem, full)

      :end ->
        nil
    end
  end

  def is_symmetrical?(row, idx) do
    case Enum.split(row, idx) do
      {_, []} ->
        :end

      {l, r} ->
        l
        |> Enum.reverse()
        |> Enum.zip(r)
        |> Enum.all?(fn {li, ri} -> li == ri end)
    end
  end
end
