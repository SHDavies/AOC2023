defmodule AdventOfCode.Day10 do
  alias AdventOfCode.Day10.PipeSection, as: PS

  def part1(input) do
    IO.puts("")
    IO.puts("")

    grid =
      input
      |> parse_input()

    grid
    |> find_start()
    |> traverse_grid(grid)
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn row -> String.split(row, "", trim: true) end)
  end

  def find_start(grid) do
    grid
    |> Stream.with_index()
    |> Stream.filter(fn {row, _} -> Enum.member?(row, "S") end)
    |> Stream.take(1)
    |> Enum.at(0)
    |> then(fn {row, row_idx} -> {row_idx, Enum.find_index(row, &(&1 == "S"))} end)
  end

  def traverse_grid(coords, grid) do
    coords
    |> PS.find_starting_neighbors(grid)
    |> PS.follow_pipe(grid, [coords], 0)
  end

  def part2(input) do
    grid =
      input
      |> parse_input()

    grid
    |> find_start()
    |> find_enclosed(grid)
    |> calculate_enclosed()
  end

  def find_enclosed(start_coords, grid) do
    start_coords
    |> PS.find_starting_neighbors(grid)
    |> then(fn [start, _] -> PS.follow_loop(start, [start_coords], [start_coords], grid) end)
  end

  def calculate_enclosed({traversed, corners}) do
    corners
    |> Enum.chunk_every(2, 1, Enum.take(corners, 1))
    |> Enum.map(fn [{row1, col1}, {row2, col2}] -> col1 * row2 - row1 * col2 end)
    |> Enum.sum()
    |> then(fn total -> abs(total / 2) + 1 - length(traversed) / 2 end)
  end
end

defmodule AdventOfCode.Day10.PipeSection do
  @pipes %{
    "|" => [:N, :S],
    "-" => [:E, :W],
    "L" => [:N, :E],
    "J" => [:N, :W],
    "7" => [:W, :S],
    "F" => [:E, :S],
    "." => []
  }

  def follow_loop(coords, seen, corners, grid) do
    pipe = get_pipe(coords, grid)

    corners = if Enum.member?(["L", "J", "7", "F"], pipe), do: [coords | corners], else: corners

    next =
      get_neighbors(coords, pipe)
      |> Enum.filter(fn c -> !Enum.member?(seen, c) end)

    cond do
      Enum.empty?(next) ->
        {[coords | seen], corners}

      length(next) > 1 ->
        throw("WHAT")

      true ->
        follow_loop(Enum.at(next, 0), [coords | seen], corners, grid)
    end
  end

  def follow_pipe(coords, grid, seen, steps) do
    next =
      coords
      |> Enum.map(fn coord -> {coord, get_pipe(coord, grid)} end)
      |> Enum.map(fn {coord, pipe} -> get_neighbors(coord, pipe) end)
      |> Enum.map(fn neighbors -> Enum.filter(neighbors, fn c -> !Enum.member?(seen, c) end) end)
      |> List.flatten()

    if Enum.empty?(next) do
      steps + 1
    else
      follow_pipe(next, grid, seen ++ next, steps + 1)
    end
  end

  def get_neighbors(coords, pipe) do
    pipe
    |> then(fn p -> Map.get(@pipes, p) end)
    |> Enum.map(fn dir -> follow_dir(dir, coords) end)
  end

  def follow_dir(:N, {row, col}), do: {row - 1, col}
  def follow_dir(:E, {row, col}), do: {row, col + 1}
  def follow_dir(:W, {row, col}), do: {row, col - 1}
  def follow_dir(:S, {row, col}), do: {row + 1, col}

  def find_starting_neighbors(coords, grid) do
    [:N, :E, :W, :S]
    |> Enum.map(fn dir -> follow_dir(dir, coords) end)
    |> Enum.map(fn c -> {c, get_pipe(c, grid)} end)
    |> Enum.map(fn {c, p} -> {c, get_neighbors(c, p)} end)
    |> Enum.filter(fn {_, neighbors} -> Enum.member?(neighbors, coords) end)
    |> Enum.map(fn {c, _} -> c end)
  end

  def get_pipe({row, col}, grid) do
    grid
    |> Enum.at(row)
    |> Enum.at(col)
  end
end
