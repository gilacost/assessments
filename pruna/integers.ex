# You must define the module as 'Solution' with a method named 'start'
Code.compiler_options(ignore_module_conflict: true)

defmodule Solution do
  def start do
    case read(&integer_list/1) do
      [n, m] when 0 > n or n > 20000 ->
        print_ln("0 < n and n <= 20000, #{inspect([n, m])}", :stderr)
        start()

      [n, m] when 0 > m or m > 20000 ->
        print_ln("0 < m and m <= 15000, #{inspect([n, m])}", :stderr)
        start()

      [n, m] ->
        array = read(&integer_list(&1, n))

        results =
          1..m
          |> Enum.map(fn _ ->
            value = read(&integer/1)
            value in array
          end)

        Enum.each(results, fn el ->
          el
          |> to_string()
          |> String.capitalize()
          |> IO.puts()
        end)

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

  def integer_list(data) do
    data
    |> String.split()
    |> case do
      [_n, _m] = input ->
        Enum.map(input, fn i ->
          {val, ""} = Integer.parse(i)
          val
        end)

      _ ->
        print_ln("wrong parameters", :stderr)
        start()
    end
  end

  def integer_list(data, size) do
    data
    |> String.split()
    |> Enum.take(size)
    |> Enum.map(fn i ->
      {val, ""} = Integer.parse(i)
      val
    end)
  end

  def print_ln(error, :stderr) do
    IO.puts(:stderr, "\n#{error}\n")
  end

  def print_ln(string) do
    IO.puts("#{string}")
  end
end

Solution.start()
