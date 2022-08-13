use nannou::{
  color::IntoLinSrgba,
  draw::properties::ColorScalar,
  lyon::{
      lyon_tessellation::{LineJoin, StrokeOptions},
  },
  prelude::*,
};

pub fn denorm_pt(rect: &Rect, point_normed: Point2) -> Point2 {
  let w_half = rect.w() / 2.0;
  let h_half = rect.h() / 2.0;
  let x = rect.x() + w_half * point_normed.x;
  let y = rect.y() + h_half * point_normed.y;
  pt2(x, y)
}

// Denormalize based by shorter side
pub fn denorm_f32(rect: &Rect, value_normed: f32) -> f32 {
  if rect.w() > rect.h() {
      value_normed * (rect.h() / 2.0)
  } else {
      value_normed * (rect.w() / 2.0)
  }
}
use tuple_map::tuple_map;

pub type QuadVertices = (Point2, Point2, Point2, Point2);

pub fn quad<C>(
  draw: &Draw,
  rect: &Rect,
  points_normed: QuadVertices,
  color: C,
  stroke_weight_normed: f32,
) where
  C: IntoLinSrgba<ColorScalar>,
{
  let stroke_weight = denorm_f32(rect, stroke_weight_normed);
  let rect_inner = rect.pad(stroke_weight / 2.0);

  let (an, bn, cn, dn) = points_normed;
  let (a, b, c, d) = tuple_map!((an, bn, cn, dn), x, denorm_pt(&rect_inner, x));
  let opts = StrokeOptions::default().with_line_join(LineJoin::Round);

  draw.quad()
      .no_fill()
      .stroke_opts(opts)
      .stroke_color(color)
      .stroke_weight(stroke_weight)
      .points(a, b, c, d);
}