defmodule CraftheadWeb.ImageControllerTest do
  use CraftheadWeb.ConnCase
  import Mock

  describe "get_render_options/3" do
    test "returns default render options" do
      assert CraftheadWeb.ImageController.get_render_options(:avatar, %{}) ==
               %Crafthead.Renderer.RenderOptions{
                 size: 128,
                 render_type: :avatar,
                 model: nil,
                 armored: false
               }
    end

    test "clamps to minimum size" do
      assert CraftheadWeb.ImageController.get_render_options(:avatar, %{"size" => "7"}) ==
               %Crafthead.Renderer.RenderOptions{
                 size: 8,
                 render_type: :avatar,
                 model: nil,
                 armored: false
               }
    end

    test "clamps to maximum size" do
      assert CraftheadWeb.ImageController.get_render_options(:avatar, %{"size" => "301"}) ==
               %Crafthead.Renderer.RenderOptions{
                 size: 300,
                 render_type: :avatar,
                 model: nil,
                 armored: false
               }
    end

    test "respects existing size if within range" do
      assert CraftheadWeb.ImageController.get_render_options(:avatar, %{"size" => "9"}) ==
               %Crafthead.Renderer.RenderOptions{
                 size: 9,
                 render_type: :avatar,
                 model: nil,
                 armored: false
               }
    end

    for {model_str, model_atom} <- [{"slim", :slim}, {"default", :classic}, {"classic", :classic}] do
      test "respects model override #{model_str}" do
        assert CraftheadWeb.ImageController.get_render_options(:avatar, %{
                 "model" => unquote(model_str)
               }) ==
                 %Crafthead.Renderer.RenderOptions{
                   size: 128,
                   render_type: :avatar,
                   model: unquote(model_atom),
                   armored: false
                 }
      end
    end

    test "respects armored override" do
      assert CraftheadWeb.ImageController.get_render_options(:avatar, %{}, armored: true) ==
               %Crafthead.Renderer.RenderOptions{
                 size: 128,
                 render_type: :avatar,
                 model: nil,
                 armored: true
               }
    end
  end

  describe "fallback skin rendering" do
    for endpoint <- ["avatar", "helm", "cube", "body", "bust", "armor/body", "armor/bust"] do
      test "for endpoint #{endpoint}", %{conn: conn} do
        with_mocks([
          {CraftheadWeb.Util, [:passthrough], [
            get_profile_for_entity: fn _entity -> {:error, :not_found} end,
          ]},
          {Crafthead.Renderer, [], [
            render_image: fn _image, _opts -> <<>> end,
          ]}
        ]) do
          conn = get(conn, "/#{unquote(endpoint)}/tuxed")
          assert List.keyfind(conn.resp_headers, "x-crafthead-fallback", 0) == {"x-crafthead-fallback", "alex"}

          assert_called Crafthead.Renderer.render_image(
            Crafthead.Util.Skin.load_default_skin(:alex),
            :meck.is(fn opts ->
              assert opts.model == :slim
              true
            end)
          )
        end
      end
    end

    test "respect overriden model", %{conn: conn} do
      with_mocks([
        {CraftheadWeb.Util, [:passthrough], [
          get_profile_for_entity: fn _entity -> {:error, :not_found} end,
        ]},
        {Crafthead.Renderer, [], [
          render_image: fn _image, _opts -> <<>> end,
        ]}
      ]) do
        conn = get(conn, "/avatar/tuxed?model=classic")
        assert List.keyfind(conn.resp_headers, "x-crafthead-fallback", 0) == {"x-crafthead-fallback", "alex"}

        assert_called Crafthead.Renderer.render_image(
          Crafthead.Util.Skin.load_default_skin(:alex),
          :meck.is(fn opts ->
            assert opts.model == :classic
            true
          end)
        )
      end
    end
  end
end
