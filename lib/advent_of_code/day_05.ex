defmodule AdventOfCode.Day05 do
  @map_types [
    "seed-to-soil",
    "soil-to-fertilizer",
    "fertilizer-to-water",
    "water-to-light",
    "light-to-temperature",
    "temperature-to-humidity",
    "humidity-to-location"
  ]

  def part1(input) do
    IO.puts("")

    seeds =
      Regex.named_captures(~r/^seeds:(?<seeds>.+)/, input)
      |> then(fn %{"seeds" => seeds} -> seeds end)
      |> String.trim()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> IO.inspect(limit: :infinity, label: "seeds")

    maps = make_maps(input) |> IO.inspect()

    seeds
    |> Enum.map(fn seed -> find_seed_location(seed, maps) end)
    |> Enum.min()
  end

  def make_maps(input) do
    @map_types
    |> Enum.reduce(%{}, fn m_type, acc ->
      IO.puts("building #{m_type} map")

      Regex.compile!("#{m_type}\smap:\n(?<raw>[^A-z]+)")
      |> Regex.named_captures(input)
      |> then(fn %{"raw" => raw} -> raw end)
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn mapping_str ->
        mapping_str
        |> String.split(" ")
        |> Enum.map(&String.to_integer/1)
        |> then(fn [dest, source, amt] ->
          diff = dest - source
          {source..(source + amt - 1), fn x -> x + diff end}
        end)
      end)
      |> then(fn mappings -> Map.put(acc, m_type, mappings) end)
    end)
  end

  def find_seed_location(seed, maps) do
    IO.inspect(seed, limit: :infinity, label: "finding seed location for")

    @map_types
    |> Enum.reduce(seed, fn m_type, current_val ->
      maps
      |> Map.get(m_type)
      |> Enum.find({current_val, fn x -> x end}, fn {range, _} -> current_val in range end)
      |> then(fn {_, mutation} -> mutation.(current_val) end)
    end)
  end

  def part2(input) do
    IO.puts("")

    seeds =
      Regex.named_captures(~r/^seeds:(?<seeds>.+)/, input)
      |> then(fn %{"seeds" => seeds} -> seeds end)
      |> String.trim()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, stop] -> start..(start + stop - 1) end)

    maps = make_maps_2(input)

    seeds
    |> Enum.map(fn range -> find_lowest_location(range, maps) end)
    |> List.flatten()
    |> Enum.min()
  end

  def make_maps_2(input) do
    @map_types
    |> Enum.reduce(%{}, fn m_type, acc ->
      Regex.compile!("#{m_type}\smap:\n(?<raw>[^A-z]+)")
      |> Regex.named_captures(input)
      |> then(fn %{"raw" => raw} -> raw end)
      |> String.trim()
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(fn mapping_str ->
        mapping_str
        |> String.split(" ")
        |> Enum.map(&String.to_integer/1)
        |> then(fn [dest, source, amt] ->
          {source..(source + amt - 1), dest - source}
        end)
      end)
      |> then(fn mappings -> Map.put(acc, m_type, mappings) end)
    end)
  end

  def find_lowest_location(range, maps) do
    @map_types
    |> Enum.reduce([range], fn m_type, ranges ->
      mappings =
        Map.get(maps, m_type)

      mappings
      |> Enum.reduce({[], ranges}, fn {m_min..m_max, mutation}, {mutated, unmutated} ->
        unmutated
        |> Enum.reduce({[], []}, fn r_min..r_max, {ms, unms} ->
          cond do
            r_min >= m_min and r_max <= m_max ->
              mut = Range.shift(r_min..r_max, mutation)
              {[mut | ms], unms}

            r_min < m_min and r_max > m_max ->
              mut = [Range.shift(m_min..m_max, mutation) | ms]
              unmut = [r_min..(m_min - 1) | [(m_max + 1)..r_max | unms]]
              {mut, unmut}

            r_max >= m_min and r_max <= m_max ->
              mut = [Range.shift(m_min..r_max, mutation) | ms]
              unmut = [r_min..(m_min - 1) | unms]
              {mut, unmut}

            r_min >= m_min and r_min <= m_max ->
              mut = [Range.shift(r_min..m_max, mutation) | ms]
              unmut = [(m_max + 1)..r_max | unms]
              {mut, unmut}

            true ->
              {ms, [r_min..r_max | unms]}
          end
        end)
        |> then(fn {ms, unms} -> {mutated ++ ms, unms} end)
      end)
      |> then(fn {ms, unms} -> ms ++ unms end)
    end)
    |> Enum.map(fn min.._ -> min end)
  end
end
