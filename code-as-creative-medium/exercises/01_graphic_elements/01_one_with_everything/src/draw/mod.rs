use nannou::{
  color::IntoLinSrgba,
  draw::properties::ColorScalar,
  lyon::{
      geom::traits::Transformation,
      lyon_tessellation::{LineJoin, StrokeOptions},
      math::{point, vector, Angle, Point, Vector},
      path::Path,
  },
  prelude::*,
};
use tuple_map::tuple_map;

pub mod util;

pub fn tri<C>(
  draw: &Draw,
  rect: &Rect,
  points_normed: (Point2, Point2, Point2),
  color: C,
  stroke_weight_normed: f32,
) where
  C: IntoLinSrgba<ColorScalar>,
{
  let stroke_weight = util::denorm_f32(rect, stroke_weight_normed);
  let rect_inner = rect.pad(stroke_weight / 2.0);

  let (an, bn, cn) = points_normed;
  let (a, b, c) = tuple_map!((an, bn, cn), x, util::denorm_pt(&rect_inner, x));

  let opts = StrokeOptions::default().with_line_join(LineJoin::Round);

  draw.tri()
      .no_fill()
      .stroke_opts(opts)
      .stroke_color(color)
      .stroke_weight(stroke_weight)
      .points(a, b, c);
}

pub fn quad<C>(
  draw: &Draw,
  rect: &Rect,
  points_normed: (Point2, Point2, Point2, Point2),
  color: C,
  stroke_weight_normed: f32,
) where
  C: IntoLinSrgba<ColorScalar>,
{
  let stroke_weight = util::denorm_f32(rect, stroke_weight_normed);
  let rect_inner = rect.pad(stroke_weight / 2.0);

  let (an, bn, cn, dn) = points_normed;
  let (a, b, c, d) = tuple_map!((an, bn, cn, dn), x, util::denorm_pt(&rect_inner, x));
  let opts = StrokeOptions::default().with_line_join(LineJoin::Round);

  draw.quad()
      .no_fill()
      .stroke_opts(opts)
      .stroke_color(color)
      .stroke_weight(stroke_weight)
      .points(a, b, c, d);
}

pub fn ellipse<C>(
  draw: &Draw,
  rect: &Rect,
  width_ratio: f32,
  height_ratio: f32,
  rotate_angle: f32,
  color: C,
  stroke_weight_normed: f32,
) where
  C: IntoLinSrgba<ColorScalar>,
{
  let stroke_weight = util::denorm_f32(rect, stroke_weight_normed);
  let rect_inner = rect.pad(stroke_weight / 2.0);

  let (w, h) = util::ratio_to_wh(&rect_inner, width_ratio, height_ratio);

  let opts = StrokeOptions::default().with_line_join(LineJoin::Round);

  draw.ellipse()
      .stroke_opts(opts)
      .stroke_color(color)
      .stroke_weight(stroke_weight)
      .x(rect_inner.x())
      .y(rect_inner.y())
      .w(w)
      .h(h)
      .rotate(rotate_angle);
}

pub fn line<C>(
  draw: &Draw,
  rect: &Rect,
  start_normed: Point2,
  end_normed: Point2,
  dot1_normed: Point2,
  dot2_normed: Point2,
  color: C,
  stroke_weight_normed: f32,
  dot_size_normed: f32,
) where
  C: IntoLinSrgba<ColorScalar> + Copy,
{
  let stroke_weight = util::denorm_f32(rect, stroke_weight_normed);
  let dot_size = util::denorm_f32(rect, dot_size_normed);

  let rect_inner = rect.pad(stroke_weight / 2.0);

  let start = util::denorm_pt(&rect_inner, start_normed);
  let end = util::denorm_pt(&rect_inner, end_normed);
  let dot1 = util::denorm_pt(&rect_inner, dot1_normed);
  let dot2 = util::denorm_pt(&rect_inner, dot2_normed);

  draw.line()
      .color(color)
      .start(start)
      .end(end)
      .weight(stroke_weight)
      .start_cap_round()
      .end_cap_round();

  draw.ellipse().color(color).xy(dot1).w_h(dot_size, dot_size);
  draw.ellipse().color(color).xy(dot2).w_h(dot_size, dot_size);
}

pub fn path<C>(draw: &Draw, rect: &Rect, path_normed: Path, color: C, stroke_weight_normed: f32)
where
  C: IntoLinSrgba<ColorScalar>,
{
  let stroke_weight = util::denorm_f32(rect, stroke_weight_normed);
  let rect_inner = rect.pad(stroke_weight / 2.0);

  let transform = DenormTransform::new(rect_inner);
  let path = path_normed.transformed(&transform);
  draw.path()
      .stroke()
      .weight(stroke_weight)
      .color(color)
      .start_cap_round()
      .end_cap_round()
      .join_round()
      .events(path.iter());
}

struct DenormTransform {
  rect: Rect,
}

impl DenormTransform {
  fn new(rect: Rect) -> Self {
      DenormTransform { rect }
  }
}

impl Transformation<f32> for DenormTransform {
  fn transform_point(&self, p: Point) -> Point {
      let v = util::denorm_pt(&self.rect, pt2(p.x, p.y));
      point(v.x, v.y)
  }
  fn transform_vector(&self, p: Vector) -> Vector {
      let v = util::denorm_pt(&self.rect, pt2(p.x, p.y));
      vector(v.x, v.y)
  }
}

pub fn polyline<C>(
  draw: &Draw,
  rect: &Rect,
  points_normed: Vec<Point2>,
  color: C,
  stroke_weight_normed: f32,
) where
  C: IntoLinSrgba<ColorScalar>,
{
  let stroke_weight = util::denorm_f32(rect, stroke_weight_normed);
  let rect_inner = rect.pad(stroke_weight / 2.0);
  let points = points_normed
      .iter()
      .map(|p| util::denorm_pt(&rect_inner, p.clone()));
  draw.polyline()
      .color(color)
      .weight(stroke_weight)
      .start_cap_round()
      .end_cap_round()
      .join_round()
      .points(points);
}

pub fn arc<C>(
  draw: &Draw,
  rect: &Rect,
  radius_normed: f32,
  start_angle: f32,
  sweep_angle: f32,
  color: C,
  stroke_weight_normed: f32,
) where
  C: IntoLinSrgba<ColorScalar>,
{
  let stroke_weight = util::denorm_f32(rect, stroke_weight_normed);
  let rect_inner = rect.pad(stroke_weight / 2.0);

  let radius = util::denorm_f32(&rect_inner, radius_normed);

  let mut builder = Path::builder().with_svg();
  let center = point(rect_inner.x(), rect_inner.y());
  let radii = vector(radius, radius);
  builder.move_to(point(rect_inner.x(), rect_inner.y()));
  builder.line_to(point(
      rect_inner.x() + radius * start_angle.cos(),
      rect_inner.y() + radius * start_angle.sin(),
  ));
  builder.arc(
      center,
      radii,
      Angle::radians(sweep_angle),
      Angle::radians(0.0),
  );
  builder.close();

  let path = builder.build();
  draw.path()
      .stroke()
      .weight(stroke_weight)
      .color(color)
      .start_cap_round()
      .end_cap_round()
      .join_round()
      .events(path.iter());
}