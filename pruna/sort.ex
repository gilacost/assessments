# You must define the module as 'Solution' with a method named 'start'
Code.compiler_options(ignore_module_conflict: true)

defmodule Solution do
  def start do
    IO.puts("Input")

    case read(&integer/1) do
      n_words when 0 > n_words or n_words > 50000 ->
        print_ln("0 < n and n <= 50000, #{inspect(n_words)}", :stderr)
        start()

      n_words when is_integer(n_words) ->
        read(&words/1)
        |> Enum.take(n_words)
        |> Enum.sort()
        |> Enum.join(" ")
        |> IO.puts()

      _ ->
        print_ln("first input should be a list of two integers [n, m]", :stderr)
        start()
    end
  end

  def read(parser) do
    case IO.read(:stdio, :line) do
      :eof ->
        :ok

      {:error, reason} ->
        IO.puts("Error: #{reason}")
        read(parser)

      data ->
        parser.(data)
    end
  end

  def integer(data) do
    {int, _} =
      data
      |> String.replace_trailing("\n", "")
      |> Integer.parse()

    int
  end

  def words(sentence) do
    sentence
    |> String.replace_trailing("\n", "")
    |> String.split()
  end

  def print_ln(error, :stderr) do
    IO.puts(:stderr, "\n#{error}\n")
  end

  def print_ln(string) do
    IO.puts("#{string}")
  end
end

Solution.start()
