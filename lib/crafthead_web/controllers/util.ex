defmodule CraftheadWeb.Util do
  @always_renders_steve_uuid "fffffff0fffffff0fffffff0fffffff0"

  alias Crafthead.Clients.Mojang
  alias Crafthead.Profile.Minecraft
  alias Crafthead.Util.Request

  @doc ~S"""
  Depending on the entity tuple given, get the profile for the entity.

  This function will try to avoid any lookups for clearly invalid entities.
  """
  def get_profile_for_entity({:uuid, entity}) do
    if Request.is_v3_uuid(entity) do
      # we know this isn't going to work
      {:error, :not_found}
    else
      case Mojang.uuid_to_profile(entity) do
        {:ok, profile} -> {:ok, profile}
        # If we can't find the profile, we'd like to render a fallback.
        {:error, :not_found} -> {:ok, %Minecraft{id: entity, name: entity, properties: []}}
        {:error, error} -> {:error, error}
      end
    end
  end

  def get_profile_for_entity({:username, entity} = raw_entity) do
    case Mojang.username_to_uuid(entity) do
      {:ok, uuid} -> get_profile_for_entity({:uuid, uuid})
      {:error, error} -> {:error, error}
    end
  end

  def get_potentially_fake_profile_from_entity({:uuid, entity} = raw_entity) do
    case get_profile_for_entity(raw_entity) do
      {:ok, profile} -> {:ok, profile}
      # If we can't find the profile, we'd like to render a fallback.
      {:error, :not_found} -> {:ok, %Minecraft{id: entity, name: entity, properties: []}}
      {:error, error} -> {:error, error}
    end
  end

  def get_potentially_fake_profile_from_entity({:username, "char"}) do
    # For convenience, just make these use a UUID that will always result in a Steve skin.
    {:ok,
     %Minecraft{
       id: @always_renders_steve_uuid,
       name: "char",
       properties: []
     }}
  end

  def get_potentially_fake_profile_from_entity({:username, "MHF_Steve"}) do
    # For convenience, just make these use a UUID that will always result in a Steve skin.
    {:ok,
     %Minecraft{
       id: @always_renders_steve_uuid,
       name: "MHF_Steve",
       properties: []
     }}
  end

  def get_potentially_fake_profile_from_entity({:username, entity} = raw_entity) do
    case get_profile_for_entity(raw_entity) do
      {:ok, profile} ->
        {:ok, profile}

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
