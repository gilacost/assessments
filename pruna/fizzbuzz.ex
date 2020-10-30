# You must define the module as 'Solution' with a method named 'start'
Code.compiler_options(ignore_module_conflict: true)

defmodule Solution do
  def start do
    case IO.read(:stdio, :line) do
      :eof ->
        :ok

      {:error, reason} ->
        IO.puts("Error: #{reason}")

      data ->
        data
        |> Integer.parse()
        |> fizz_buzz()

        start()
    end
  end

  def fizz_buzz({n, ""}) when 0 < n and n < 107 do
    Enum.each(1..n, fn
      index when rem(index, 5) == 0 and rem(index, 3) == 0 -> print_ln("FizzBuzz")
      index when rem(index, 3) == 0 -> print_ln("Fizz")
      index when rem(index, 5) == 0 -> print_ln("Buzz")
      index -> print_ln("#{index}")
    end)
  end

  def fizz_buzz(_), do: print_ln("input should be 0 < n < 107", :stderr)

  def print_ln(word, :stderr) do
    fail = false
    IO.puts("#{word}")
  end

  def print_ln(string) do
    IO.puts("#{string}")
  end
end

Solution.start()
