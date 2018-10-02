defmodule Identicon do
  @moduledoc """
    Generates an identicon based on a string
  """

  def main(input) do
    input
    |> hash_string
    |> pick_color
    |> build_grid
    |> filter_odd_squares
  end

  @doc """
    Returns an Identicon.Image struct, containing hex as a list of integers representing hash.
    The `input` is a string to calculate hash.

  ## Example

      iex> Identicon.hash_string("identicon")
      %Identicon.Image{
        color: %Identicon.Color{blue: 0, green: 0, red: 0},
        hex: [173, 43, 65, 97, 60, 135, 2, 181, 55, 43, 189, 201, 168, 16, 112, 64]
      }

  """
  def hash_string(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
    Returns an Identicon.Image struct, containing a RGB color as a list of integers.
    The `image` is a Identicon.Image struct to calculate RGB color.

  ## Example

      iex> image = Identicon.hash_string("identicon")
      iex> Identicon.pick_color(image)
      %Identicon.Image{
        color: %Identicon.Color{blue: 65, green: 43, red: 173},
        hex: [173, 43, 65, 97, 60, 135, 2, 181, 55, 43, 189, 201, 168, 16, 112, 64]
      }

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _rest_of_hex]} = image) do
    %Identicon.Image{image | color: %Identicon.Color{red: r, green: g, blue: b}}
  end

  @doc """
    Returns an Identicon.Image struct, containing a list of integers lists representing a grid.
    The `image` is a Identicon.Image struct to generate a grid.

  ## Example

      iex> image = Identicon.hash_string("identicon")
      iex> Identicon.build_grid(image)
      %Identicon.Image{
        color: %Identicon.Color{blue: 0, green: 0, red: 0},
        grid: [
          {43, 0}, {65, 1}, {97, 2}, {65, 3}, {43, 4},
          {60, 5}, {135, 6}, {2, 7}, {135, 8}, {60, 9},
          {181, 10}, {55, 11}, {43, 12}, {55, 13}, {181, 14},
          {189, 15}, {201, 16}, {168, 17}, {201, 18}, {189, 19},
          {16, 20}, {112, 21}, {64, 22}, {112, 23}, {16, 24}
        ],
        hex: [173, 43, 65, 97, 60, 135, 2, 181, 55, 43, 189, 201, 168, 16, 112, 64]
      }

  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> tl
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.flat_map(&mirror_row/1)
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Returns a row mirrored by the last element.
    The `row` is any list of data

  ## Example

      iex> Identicon.mirror_row([1, 2, 3])
      [1, 2, 3, 2, 1]

  """
  def mirror_row(row) do
    right_side =
      row
      |> :lists.reverse
      |> tl

    row ++ right_side
  end

  @doc """
    Returns an Identicon.Image struct, containing a filtered (by even) list of integers lists representing a grid.
    The `image` is a Identicon.Image struct to filter even integers from a grid data.

  ## Example

      iex> image = Identicon.hash_string("identicon")
      iex> grid = Identicon.build_grid(image)
      iex> Identicon.filter_odd_squares(grid)
      %Identicon.Image{
        color: %Identicon.Color{blue: 0, green: 0, red: 0},
        grid: [
          {60, 5},
          {2, 7},
          {60, 9},
          {168, 17},
          {16, 20},
          {112, 21},
          {64, 22},
          {112, 23},
          {16, 24}
        ],
        hex: [173, 43, 65, 97, 60, 135, 2, 181, 55, 43, 189, 201, 168, 16, 112, 64]
      }

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    painted_cells = Enum.filter grid, fn {value, _index} = _cell ->
      rem(value, 2) == 0
    end

    %Identicon.Image{image | grid: painted_cells}
  end
end
