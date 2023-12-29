defmodule Crafthead.Renderer.RenderOptions do
  defstruct render_type: nil,
            size: nil,
            armored: false,
            model: nil

  use ExConstructor
end

defmodule Crafthead.Renderer do
  use Rustler, otp_app: :crafthead, crate: "crafthead_renderer"

  def render_image(_skin_image, _options), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
