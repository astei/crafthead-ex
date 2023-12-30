defmodule CraftheadWeb.ImageControllerTest do
  use CraftheadWeb.ConnCase, async: true
  # use ExUnit.Parameterized

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
end
