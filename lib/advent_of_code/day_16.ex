defmodule AdventOfCode.Day16 do
  def part1(input) do
    input
    |> parse()
    |> then(fn {grid, _, _} = g ->
      {0, 0}
      |> get_dirs(:right, grid)
      |> Enum.map(fn dir -> {0, 0, dir} end)
      |> then(fn beams -> trace_beams(beams, %{}, g) end)
    end)
  end

  def part2(input) do
    grid =
      input
      |> parse()

    grid
    |> get_all_starts()
    |> Task.async_stream(&trace_beams([&1], %{}, grid))
    |> Enum.max_by(fn {:ok, lit} -> lit end)
    |> then(&elem(&1, 1))
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, row_idx} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reject(&(elem(&1, 0) == "."))
      |> Enum.map(fn {cell, idx} -> {row_idx, idx, cell} end)
    end)
    |> Enum.reduce(%{}, fn {row, col, <<cell>>}, acc -> Map.put(acc, {row, col}, cell) end)
    |> then(fn grid ->
      {
        grid,
        Enum.max_by(grid, fn {{r, _}, _} -> r end) |> elem(0) |> elem(0),
        Enum.max_by(grid, fn {{_, c}, _} -> c end) |> elem(0) |> elem(1)
      }
    end)
  end

  def trace_beams(beams, seen, grid) do
    beams
    |> Enum.flat_map(fn beam -> find_next(beam, grid) end)
    |> Enum.reject(fn {new_r, new_c, dir} ->
      case Map.get(seen, {new_r, new_c}) do
        nil -> false
        dirs -> MapSet.member?(dirs, dir)
      end
    end)
    |> then(fn new_beams ->
      seen =
        beams
        |> Enum.reduce(seen, fn {row, col, dir}, acc ->
          Map.update(acc, {row, col}, MapSet.new([dir]), &MapSet.put(&1, dir))
        end)

      if !Enum.empty?(new_beams) do
        trace_beams(new_beams, seen, grid)
      else
        map_size(seen)
      end
    end)
  end

  def find_next({row, col, dir}, {grid, max_row, max_col}) do
    {new_row, new_col} =
      case dir do
        :right -> {row, col + 1}
        :up -> {row - 1, col}
        :left -> {row, col - 1}
        :down -> {row + 1, col}
      end

    new_dirs =
      if new_row >= 0 and new_row <= max_row and new_col >= 0 and new_col <= max_col do
        get_dirs({new_row, new_col}, dir, grid)
      else
        []
      end

    Enum.map(new_dirs, fn d -> {new_row, new_col, d} end)
  end

  def get_dirs({new_row, new_col}, dir, grid) do
    case Map.get(grid, {new_row, new_col}) do
      nil ->
        [dir]

      ?- ->
        case dir do
          d when d in [:down, :up] -> [:left, :right]
          d -> [d]
        end

      ?| ->
        case dir do
          d when d in [:left, :right] -> [:up, :down]
          d -> [d]
        end

      ?\\ ->
        case dir do
          :left -> [:up]
          :up -> [:left]
          :down -> [:right]
          :right -> [:down]
        end

      ?/ ->
        case dir do
          :left -> [:down]
          :up -> [:right]
          :down -> [:left]
          :right -> [:up]
        end
    end
  end

  def draw_result(seen, {_, max_row, max_col}) do
    for r <- 0..max_row do
      for c <- 0..max_col do
        if Map.has_key?(seen, {r, c}), do: "#", else: "."
      end
      |> Enum.join()
      |> IO.puts()
    end
  end

  def get_all_starts({grid, max_row, max_col}) do
    0..max_row
    |> Enum.flat_map(fn row ->
      0..max_col
      |> Enum.flat_map(fn col ->
        case {row, col} do
          {0, 0} -> [{row, col, :right}, {row, col, :down}]
          {0, ^max_col} -> [{row, col, :left}, {row, col, :down}]
          {^max_row, 0} -> [{row, col, :right}, {row, col, :up}]
          {^max_row, ^max_col} -> [{row, col, :up}, {row, col, :left}]
          {0, _} -> [{row, col, :down}]
          {_, 0} -> [{row, col, :right}]
          {^max_row, _} -> [{row, col, :up}]
          {_, ^max_col} -> [{row, col, :left}]
          _ -> []
        end
      end)
    end)
    |> Enum.flat_map(fn {row, col, dir} ->
      get_dirs({row, col}, dir, grid) |> Enum.map(&{row, col, &1})
    end)
  end
end
