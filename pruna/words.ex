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
        |> String.split()
        |> words()

        start()
    end
  end

  def words([times, word]) do
    {times, ""} = Integer.parse(times)
    Enum.each(1..times, &IO.puts("#{&1} #{word}"))
  end
end

Solution.start()
