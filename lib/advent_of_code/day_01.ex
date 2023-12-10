defmodule AdventOfCode.Day01 do
  @digit_or_word_regex "\\d|one|two|three|four|five|six|seven|eight|nine"
  @two_num_regex Regex.compile!(
                   "(?<first>#{@digit_or_word_regex}).*(?<last>#{@digit_or_word_regex})"
                 )
  @single_digit_regex Regex.compile!("(?<only>#{@digit_or_word_regex})")
  @words_to_digits %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  def part1(input) do
    IO.puts("")

    input
    |> String.split("\n")
    |> Enum.map(&parse_row/1)
    |> Enum.sum()
  end

  def parse_row(row) do
    Regex.named_captures(@two_num_regex, row)
    |> then(fn match ->
      case match do
        %{"first" => first, "last" => last} ->
          first = Map.get(@words_to_digits, first, first)
          last = Map.get(@words_to_digits, last, last)
          String.to_integer(first <> last)

        _ ->
          %{"only" => only} = Regex.named_captures(@single_digit_regex, row)
          only = Map.get(@words_to_digits, only, only)
          String.to_integer(only <> only)
      end
    end)
  end

  def part2(input) do
    IO.puts("")

    input
    |> String.split("\n")
    |> Enum.map(&parse_row/1)
    |> Enum.sum()
  end
end
