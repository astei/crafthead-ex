defmodule Crafthead.Profile.Minecraft do
  @doc """
  Implements a raw representation of a Minecraft profile, from the Mojang API. Includes a convenience function to
  obtain the skin information for a player.
  """
  @permitted_skin_models %{"classic" => :classic, "slim" => :slim}

  @derive Jason.Encoder
  defstruct [:id, :name, :properties]
  use ExConstructor

  def get_skin_info(profile) do
    textures_property =
      profile
      |> find_texture_property()
      |> decode_texture_property!()

    %{
      skin: textures_property |> get_skin_texture_info(),
      cape: textures_property |> get_cape_texture_url()
    }
  end

  defp find_texture_property(profile) do
    Enum.find(profile.properties, fn property ->
      property["name"] == "textures"
    end)
  end

  defp decode_texture_property!(property) when is_map(property) do
    property["value"]
    |> Base.decode64!()
    |> Jason.decode!()
  end

  defp decode_texture_property!(property) when is_nil(property), do: nil

  defp get_skin_texture_info(textures_property) when is_map(textures_property) do
    if Map.has_key?(textures_property["textures"], "SKIN") do
      model =
        Map.get(textures_property["textures"]["SKIN"], "metadata", %{})
        |> Map.get("model", "classic")

      %{
        url: textures_property["textures"]["SKIN"]["url"],
        model: @permitted_skin_models[model]
      }
    else
      nil
    end
  end

  defp get_skin_texture_info(textures_property) when is_nil(textures_property), do: nil

  defp get_cape_texture_url(textures_property) when is_map(textures_property) do
    if Map.has_key?(textures_property["textures"], "CAPE") do
      textures_property["textures"]["CAPE"]["url"]
    else
      nil
    end
  end

  defp get_cape_texture_url(textures_property) when is_nil(textures_property), do: nil
end
