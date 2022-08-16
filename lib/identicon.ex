defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
    Saves Identicon Image to disk with the original input as name
  """
  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

  @doc """
    Use egd module to draw the image
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)
    IO.inspect(pixel_map)

    Enum.each pixel_map, fn({start,stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

@doc """
  Creates a list of bytes from the md5 hash of the input

  ## Examples
      iex> %Identicon.Image{hex: hex} = Identicon.hash_input("test")
      iex> hex
      [9, 143, 107, 205, 70, 33, 211, 115, 202, 222, 78, 131, 38, 39, 180, 246]

"""
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
      |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
    Create a pixel map with coordinates for the top-left and bottom-right of each square that should be filled

    ## Examples
        iex> %Identicon.Image{pixel_map: pixel_map} = Identicon.hash_input("test") |> Identicon.build_grid |> Identicon.build_pixel_map
        iex> pixel_map
        [
          {{0, 0}, {50, 50}},
          {{50, 0}, {100, 50}},
          {{100, 0}, {150, 50}},
          {{150, 0}, {200, 50}},
          {{200, 0}, {250, 50}},
          {{0, 50}, {50, 100}},
          {{50, 50}, {100, 100}},
          {{100, 50}, {150, 100}},
          {{150, 50}, {200, 100}},
          {{200, 50}, {250, 100}},
          {{0, 100}, {50, 150}},
          {{50, 100}, {100, 150}},
          {{100, 100}, {150, 150}},
          {{150, 100}, {200, 150}},
          {{200, 100}, {250, 150}},
          {{0, 150}, {50, 200}},
          {{50, 150}, {100, 200}},
          {{100, 150}, {150, 200}},
          {{150, 150}, {200, 200}},
          {{200, 150}, {250, 200}},
          {{0, 200}, {50, 250}},
          {{50, 200}, {100, 250}},
          {{100, 200}, {150, 250}},
          {{150, 200}, {200, 250}},
          {{200, 200}, {250, 250}}
        ]

  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index,5) * 50
      vertical = div(index,5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end


  @doc """
    Selects color using the first three items as RGB values.

    ## Examples

        iex> image = Identicon.hash_input("test")
        iex> %Identicon.Image{color: color} = Identicon.pick_color(image)
        iex> color

        {9, 143, 107}

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r,g,b}}
  end

  @doc """
    Builds 5X5 grid from the 16 value list of hex values and adds an idex to each value

    ## Examples
        iex> %Identicon.Image{grid: grid} = Identicon.hash_input("test") |> Identicon.build_grid
        iex> grid
        [{9, 0}, {143, 1}, {107, 2}, {143, 3}, {9, 4},
        {205, 5}, {70, 6}, {33, 7}, {70, 8}, {205, 9},
        {211, 10}, {115, 11}, {202, 12}, {115, 13}, {211, 14},
        {222, 15}, {78, 16}, {131, 17}, {78, 18}, {222, 19},
        {38, 20}, {39, 21}, {180, 22}, {39, 23}, {38, 24}]

  """
  def build_grid (%Identicon.Image{hex: hex} = image) do
    grid = hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Takes a 3 item list and mirrors it around the 3rd position such that
    the values in position 2 and 1 are copied into positions 4 and 5 respectively

    ## Examples
        iex> Identicon.mirror_row([1,2,3])
        [1, 2, 3, 2, 1]
  """
  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  @doc """
    Filter out odd squares


    ## Examples
        iex> %Identicon.Image{grid: grid} = "test" |> Identicon.hash_input |> Identicon.pick_color |> Identicon.build_grid |> Identicon.filter_odd_squares
        iex> grid
        [
          {70, 6},
          {70, 8},
          {202, 12},
          {222, 15},
          {78, 16},
          {78, 18},
          {222, 19},
          {38, 20},
          {180, 22},
          {38, 24}
        ]

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code,2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

end
