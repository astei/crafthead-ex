defmodule Crafthead.Util.Skin do
  @doc ~S"""
  Given the Minecraft UUID `uuid`, determine the fallback skin the client would use if it could
  not reach the Mojang servers.

  ## Examples

    iex> Crafthead.Util.Skin.fallback_skin_type("fffffff0fffffff0fffffff0fffffff0")
    :steve
    iex> Crafthead.Util.Skin.fallback_skin_type("fffffff0fffffff0fffffff0fffffff1")
    :alex

  """
  def fallback_skin_type(uuid) do
    [7, 15, 23, 31]
    |> Enum.map(fn i -> String.slice(uuid, i, 1) end)
    |> Enum.map(fn i -> String.to_integer(i, 16) end)
    |> Enum.reduce(fn i, acc -> Bitwise.bxor(i, acc) end)
    |> rem(2)
    |> case do
      0 -> :steve
      1 -> :alex
    end
  end

  def load_default_skin(skin) do
    file_name =
      case skin do
        :steve -> "steve.png"
        :alex -> "alex.png"
        _ -> raise "invalid skin type"
      end

    File.read!(Path.join([:code.priv_dir(:crafthead), "fallback_skins", file_name]))
  end
end
