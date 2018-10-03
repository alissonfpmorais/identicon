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
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
    Returns an Identicon.Image struct, containing hex as a list of integers representing hash.

    The `input` is a string to calculate hash.

  ## Example

      iex> Identicon.hash_string("identicon")
      %Identicon.Image{
        color: {},
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
        color: {173, 43, 65},
        grid: [],
        hex: [173, 43, 65, 97, 60, 135, 2, 181, 55, 43, 189, 201, 168, 16, 112, 64],
        painted_cells: [],
        pixel_map: {}
      }

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _rest_of_hex]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Returns an Identicon.Image struct, containing a list of integers lists representing a grid.

    The `image` is a Identicon.Image struct to generate a grid.

  ## Example

      iex> image = Identicon.hash_string("identicon")
      iex> Identicon.build_grid(image)
      %Identicon.Image{
        color: {},
        grid: [
          {43, 0}, {65, 1}, {97, 2}, {65, 3}, {43, 4},
          {60, 5}, {135, 6}, {2, 7}, {135, 8}, {60, 9},
          {181, 10}, {55, 11}, {43, 12}, {55, 13}, {181, 14},
          {189, 15}, {201, 16}, {168, 17}, {201, 18}, {189, 19},
          {16, 20}, {112, 21}, {64, 22}, {112, 23}, {16, 24}
        ],
        hex: [173, 43, 65, 97, 60, 135, 2, 181, 55, 43, 189, 201, 168, 16, 112, 64],
        painted_cells: [],
        pixel_map: {}
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

    The `row` is any list of data.

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
      iex> image = Identicon.build_grid(image)
      iex> Identicon.filter_odd_squares(image)
      %Identicon.Image{
        color: {},
        grid: [
          {43, 0}, {65, 1}, {97, 2}, {65, 3}, {43, 4},
          {60, 5}, {135, 6}, {2, 7}, {135, 8}, {60, 9},
          {181, 10}, {55, 11}, {43, 12}, {55, 13}, {181, 14},
          {189, 15}, {201, 16}, {168, 17}, {201, 18}, {189, 19},
          {16, 20}, {112, 21}, {64, 22}, {112, 23}, {16, 24}
        ],
        hex: [173, 43, 65, 97, 60, 135, 2, 181, 55, 43, 189, 201, 168, 16, 112, 64],
        painted_cells: [
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
        pixel_map: {}
      }

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    painted_cells = Enum.filter grid, fn {value, _index} = _cell ->
      rem(value, 2) == 0
    end

    %Identicon.Image{image | painted_cells: painted_cells}
  end

  @doc """
    Returns an Identicon.Image struct, containing a pixel map representing squares to be colored.

    The `image` is a Identicon.Image struct to transform `painted_cells` in `pixel_map`.

  ## Example

      iex> image = Identicon.hash_string("identicon")
      iex> image = Identicon.build_grid(image)
      iex> image = Identicon.filter_odd_squares(image)
      iex> Identicon.build_pixel_map(image)
      %Identicon.Image{
        color: {},
        grid: [
          {43, 0}, {65, 1}, {97, 2}, {65, 3}, {43, 4},
          {60, 5}, {135, 6}, {2, 7}, {135, 8}, {60, 9},
          {181, 10}, {55, 11}, {43, 12}, {55, 13}, {181, 14},
          {189, 15}, {201, 16}, {168, 17}, {201, 18}, {189, 19},
          {16, 20}, {112, 21}, {64, 22}, {112, 23}, {16, 24}
        ],
        hex: [173, 43, 65, 97, 60, 135, 2, 181, 55, 43, 189, 201, 168, 16, 112, 64],
        painted_cells: [
          {60, 5}, {2, 7}, {60, 9},
          {168, 17}, {16, 20}, {112, 21},
          {64, 22}, {112, 23}, {16, 24}
        ],
        pixel_map: [
          {{2, 52}, {48, 98}},
          {{102, 52}, {148, 98}},
          {{202, 52}, {248, 98}},
          {{102, 152}, {148, 198}},
          {{2, 202}, {48, 248}},
          {{52, 202}, {98, 248}},
          {{102, 202}, {148, 248}},
          {{152, 202}, {198, 248}},
          {{202, 202}, {248, 248}}
        ]
      }

  """
  def build_pixel_map(%Identicon.Image{grid: grid, painted_cells: painted_cells} = image) do
    pixel_map = Enum.map painted_cells, fn {_value, index} = _painted_cell ->
      length(grid)
        |> :math.sqrt
        |> round
        |> get_coordinates(index)
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    Returns a tuple of tuples, representing two coordinates (x, y) in space.

    The `size` means "how many cells has in this space/plane".

    The `index` means the cell position in this space.

  ## Example

    Get coordinate of X in this plane:
    ._._._.
    |_|_|_|
    |_|_|X|
    |_|_|_|

      iex> Identicon.get_coordinates(3, 5)
      {{102, 52}, {148, 98}}

  """
  def get_coordinates(size, index) do
    top_left_x = rem(index, size) * 50 + 2
    top_left_y = div(index, size) * 50 + 2
    bot_right_x = top_left_x + 46
    bot_right_y = top_left_y + 46

    {{top_left_x, top_left_y}, {bot_right_x, bot_right_y}}
  end

  @doc """
    Returns a raw image (generated by Erlang's :egd).

    The `image` is a Identicon.Image struct to generate a raw image.
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map} = _image) do
    raw_image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn {top_left, bot_right} = _coordinates ->
      :egd.filledRectangle(raw_image, top_left, bot_right, fill)
    end

    :egd.render(raw_image)
  end

  @doc """
    Returns a tuple {status, result}.

    Status could be both: `:ok` or `:error`.

    Result could be both: `path` or `Something went wrong`.

    The `image` is a raw image (generated by Erlang's :egd).
    
    The `path` is a absolute path to where image will be saved.
  """
  def save_image(image, path) do
    case File.write("#{path}.png", image) do
      :ok -> {:ok, path}
      {:error, _reason} -> {:error, "Something went wrong" }
    end
  end
end
