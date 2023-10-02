defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  defp build_pixel_map(%Identicon.Image{ grid: grid } = image) do
    pixel_map = Enum.map(grid, fn { _, index } ->
      h_dist = rem(index, 5) * 50
      v_dist = div(index, 5) * 50

      top_l = { h_dist, v_dist }
      bottom_r = { h_dist + 50, v_dist + 50 }
      { top_l, bottom_r }
    end)

    %Identicon.Image{ image | pixel_map: pixel_map }
  end

  defp draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {top_l, bottom_r} ->
      :egd.filledRectangle(image, top_l, bottom_r, fill)
    end)

    :egd.render(image)
  end

  defp save_image(image, input) do
    File.write("#{input}.png", image)
  end

  defp build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3)
      |> Enum.take(5)
      |> Enum.map(&mirror/1)
      |> List.flatten
      |> Enum.with_index
      |> filter_odd_squares

    %Identicon.Image{image | grid: grid}
  end

  defp pick_color(%Identicon.Image{hex: [r, g, b | _]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  defp mirror(row) do
    [first, second | _] = row

    row ++ [second, first]
  end

  defp filter_odd_squares(grid) do
    grid |> Enum.filter(fn {x, _} -> rem(x, 2) == 0 end)
  end

  defp hash_input(input) do
    hex = :crypto.hash(:md5, input) |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end
end
