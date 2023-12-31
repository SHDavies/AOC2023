defmodule AdventOfCode.Day11Test do
  use ExUnit.Case

  import AdventOfCode.Day11

  @tag :skip
  test "part1" do
    input =
      "...#......
      .......#..
      #.........
      ..........
      ......#...
      .#........
      .........#
      ..........
      .......#..
      #...#....."

    result = part1(input)

    assert result == 374
  end

  @tag :skip
  test "part2" do
    input =
      "...#......
      .......#..
      #.........
      ..........
      ......#...
      .#........
      .........#
      ..........
      .......#..
      #...#....."

    result = part2(input)

    assert result == 1030
  end
end
