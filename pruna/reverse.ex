defmodule Solution do
  def start do
    case read(&integer/1) do
      n when 0 < n and n <= 100 ->
        1..n
        |> Enum.map(fn _ ->
          read(&sentences/1)
          |> count_words()
          |> word_length()
          |> case do
            :ok ->
              nil

            words ->
              Enum.join(words, " ")
          end
        end)
        |> Enum.each(&IO.puts/1)

      _ ->
        print_ln("input should be 0 < n <= 100", :stderr)
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
    int =
      data
      |> String.replace_trailing("\n", "")
      |> Integer.parse()
      |> elem(0)

    int
  end

  def sentences(sentence) do
    sentence
    |> String.replace_trailing("\n", "")
    |> String.split()
    |> Enum.map(&String.reverse/1)
  end

  def count_words(:ok), do: :ok

  def count_words(words) when length(words) < 100 do
    words
  end

  def count_words(_words) do
    print_ln("sentence should have less thatn 100 words", :stderr)
    Process.sleep(200)
    start()
  end

  def word_length(:ok), do: :ok

  def word_length(words) do
    words
    |> Enum.reduce_while(
      0,
      fn word, err ->
        if String.length(word) > 20 do
          {:halt, {:error, "a word can't exceed 20 characters"}}
        else
          {:cont, err}
        end
      end
    )
    |> case do
      {:error, msg} ->
        print_ln(msg, :stderr)
        Process.sleep(200)
        start()

      _ ->
        words
    end
  end

  def print_ln(word, :stderr) do
    IO.puts(:stderr, "#{word}")
  end

  def print_ln(string) do
    IO.puts("#{string}")
  end
end

Solution.start()
