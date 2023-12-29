defmodule CraftheadWeb.Util do
  @always_renders_steve_uuid "fffffff0fffffff0fffffff0fffffff0"

  alias Crafthead.Clients.Mojang
  alias Crafthead.Profile.Minecraft

  def get_profile_from_entity({:uuid, entity}) do
    case Mojang.uuid_to_profile(entity) do
      {:ok, profile} -> {:ok, profile}
      # If we can't find the profile, we'd like to render a fallback.
      {:error, :not_found} -> {:ok, %Minecraft{id: entity, name: entity, properties: []}}
      {:error, error} -> {:error, error}
    end
  end

  def get_profile_from_entity({:username, "char"}) do
    # For convenience, just make these use a UUID that will always result in a Steve skin.
    {:ok,
     %Minecraft{
       id: @always_renders_steve_uuid,
       name: "char",
       properties: []
     }}
  end

  def get_profile_from_entity({:username, "MHF_Steve"}) do
    # For convenience, just make these use a UUID that will always result in a Steve skin.
    {:ok,
     %Minecraft{
       id: @always_renders_steve_uuid,
       name: "MHF_Steve",
       properties: []
     }}
  end

  def get_profile_from_entity({:username, entity}) do
    case Mojang.username_to_uuid(entity) do
      {:ok, uuid} ->
        get_profile_from_entity({:uuid, uuid})

      # If the username doesn't exist, render a fallback.
      {:error, :not_found} ->
        {:ok,
         %Minecraft{
           id: Crafthead.Util.Request.java_v3("OfflinePlayer:" <> entity),
           name: entity,
           properties: []
         }}

      {:error, error} ->
        {:error, error}
    end
  end
end
