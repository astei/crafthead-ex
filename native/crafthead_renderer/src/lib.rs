mod skin;
mod utils;

use std::io::Cursor;

use image::DynamicImage;
use rustler::{Binary, Env, Error, NifResult, NifStruct, NifUnitEnum, OwnedBinary};

use skin::{BodyPart, Layer, MinecraftSkin, SkinModel};

mod atoms {
    rustler::atoms! {
        // Error types.
        invalid_image,
        unable_to_render
    }
}

#[derive(Copy, Clone, NifUnitEnum)]
enum RenderType {
    Avatar,
    Helm,
    Cube,
    Body,
    Bust,
    Cape,
}

#[derive(NifStruct)]
#[module = "Crafthead.Renderer.RenderOptions"]
struct RenderOptions {
    pub render_type: RenderType,
    pub size: u32,
    pub armored: bool,
    pub model: SkinModel,
}

impl RenderType {
    fn render(self, img: &MinecraftSkin, options: &RenderOptions) -> DynamicImage {
        let size: u32 = options.size;
        match self {
            RenderType::Avatar => img
                .get_part(Layer::Bottom, BodyPart::Head, options.model)
                .resize(size, size, image::imageops::FilterType::Nearest),
            RenderType::Helm => img
                .get_part(Layer::Both, BodyPart::Head, options.model)
                .resize(size, size, image::imageops::FilterType::Nearest),
            RenderType::Cube => img.render_cube(true, size),
            RenderType::Body => img.render_body(options).resize(
                size,
                size * 2,
                image::imageops::FilterType::Nearest,
            ),
            RenderType::Bust => img.render_body(options).crop(0, 0, 16, 16).resize(
                size,
                size,
                image::imageops::FilterType::Nearest,
            ),
            RenderType::Cape => {
                img.get_cape()
                    .resize(size, size, image::imageops::FilterType::Nearest)
            }
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn render_image<'a>(
    env: Env<'a>,
    skin_image: Binary<'a>,
    options: RenderOptions,
) -> NifResult<Binary<'a>> {
    let image_copy = skin_image.as_slice();

    let skin_result = image::load_from_memory_with_format(&image_copy, image::ImageFormat::Png);
    match skin_result {
        Ok(skin_img) => {
            let skin = MinecraftSkin::new(skin_img);
            let rendered = options.render_type.render(&skin, &options);

            // We can't predict the size of the output, so we can't just write directly into an OwnedBinary.
            let mut result = Vec::with_capacity(1024);
            let mut cursor = Cursor::new(&mut result);
            return match rendered.write_to(&mut cursor, image::ImageFormat::Png) {
                Ok(()) => {
                    let mut binary = OwnedBinary::new(result.len()).unwrap();
                    binary.as_mut_slice().copy_from_slice(&result[..]);
                    Ok(Binary::from_owned(binary, env))
                }
                Err(_err) => Err(Error::Term(Box::new(atoms::unable_to_render()))),
            };
        }
        Err(_err) => Err(Error::Term(Box::new(atoms::invalid_image()))),
    }
}

rustler::init!("Elixir.Crafthead.Renderer", [render_image]);
