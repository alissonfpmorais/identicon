defmodule Identicon do
  @moduledoc """
    Generates an identicon based on a string
  """

  def main(input) do
    input
    |> hash_string
  end

  @doc """
    Returns a list of integers representing hash.
    The `input` is a string to calculate hash.

  ## Example

      iex> Identicon.hash_string("identicon")
      [173, 43, 65, 97, 60, 135, 2, 181, 55, 43, 189, 201, 168, 16, 112, 64]

  """
  def hash_string(input) do
    :crypto.hash(:md5, input)
    |> :binary.bin_to_list
  end
end
