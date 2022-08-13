use nannou::{
  color::IntoLinSrgba,
  draw::properties::ColorScalar,
  lyon::{
      math::{point, vector, Angle},
      path::Path,
  },
  prelude::*,
};
use tuple_map::tuple_map;

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

pub type TriangleVertices = (Point2, Point2, Point2);

pub fn tri<C>(
  draw: &Draw,
  rect: &Rect,
  points_normed: TriangleVertices,
  color: C,
) where
  C: IntoLinSrgba<ColorScalar>,
{
  let (an, bn, cn) = points_normed;
  let (a, b, c) = tuple_map!((an, bn, cn), x, denorm_pt(rect, x));

  draw.tri()
      .color(color)
      .points(a, b, c);
}


pub fn line<C>(
  draw: &Draw,
  rect: &Rect,
  start_normed: Point2,
  end_normed: Point2,
  color: C,
  stroke_weight_normed: f32,
) where
  C: IntoLinSrgba<ColorScalar> + Copy,
{
  let stroke_weight = denorm_f32(rect, stroke_weight_normed);
  let rect_inner = rect.pad(stroke_weight / 2.0);

  let start = denorm_pt(&rect_inner, start_normed);
  let end = denorm_pt(&rect_inner, end_normed);

  draw.line()
      .color(color)
      .start(start)
      .end(end)
      .weight(stroke_weight)
      .start_cap_round()
      .end_cap_round();
}

pub fn arc<C>(
  draw: &Draw,
  rect: &Rect,
  center_normed: Point2,
  radius_normed: f32,
  start_angle: f32,
  sweep_angle: f32,
  color: C,
  no_fill: bool,
  close: bool,
  stroke_weight_normed: f32,
) where
  C: IntoLinSrgba<ColorScalar>,
{
  let stroke_weight = denorm_f32(rect, stroke_weight_normed);
  let rect_inner = rect.pad(stroke_weight / 2.0);

  let radius = denorm_f32(&rect_inner, radius_normed);
  let center = denorm_pt(&rect_inner, center_normed);

  let mut builder = Path::builder().with_svg();
  let radii = vector(radius, radius);
  if no_fill && close {
    builder.move_to(point(center.x, center.y));
    builder.line_to(point(
        center.x + radius * start_angle.cos(),
        center.y + radius * start_angle.sin(),
    ));
  } else {
    builder.move_to(point(
      center.x + radius * start_angle.cos(),
      center.y + radius * start_angle.sin(),
    ));
  }
  builder.arc(
      point(center.x, center.y),
      radii,
      Angle::radians(sweep_angle),
      Angle::radians(0.0),
  );
  if close {
    builder.close();
  }

  let path = builder.build();

  if no_fill {
    draw.path()
        .stroke()
        .weight(stroke_weight)
        .color(color)
        .start_cap_round()
        .end_cap_round()
        .join_round()
        .events(path.iter());
  } else {
    draw.path()
        .fill()
        .color(color)
        .events(path.iter());
  }
}
