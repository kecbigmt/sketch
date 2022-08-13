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

fn main() {
    nannou::sketch(view).run();
}

const PAD_NORMED: f32 = 0.05;

fn view(app: &App, frame: Frame) {
    let draw = app.draw();
    draw.background().color(WHITE);

    let win = app.window_rect();

    let base_pad = denorm_f32(&win, PAD_NORMED);
    let base_size = win.w().min(win.h());
    let base = Rect::from_w_h(base_size, base_size).middle_of(win).pad(base_pad);
    
    let grid_pad = denorm_f32(&base, PAD_NORMED);
    let grid = Rect::from_w_h(base_size / 3.0, base_size / 3.0);

    let top_left = grid.top_left_of(base).pad(grid_pad);
    let mid_top = grid.mid_top_of(base).pad(grid_pad);
    let top_right = grid.top_right_of(base).pad(grid_pad);
    let mid_left = grid.mid_left_of(base).pad(grid_pad);
    let center = grid.middle_of(base).pad(grid_pad);
    let mid_right = grid.mid_right_of(base).pad(grid_pad);
    let bottom_left = grid.bottom_left_of(base).pad(grid_pad);
    let mid_bottom = grid.mid_bottom_of(base).pad(grid_pad);
    let bottom_right = grid.bottom_right_of(base).pad(grid_pad);

    // Triangle
    tri(
        &draw,
        &top_left,
        (pt2(0.0, 1.0), pt2(-1.0, -1.0), pt2(1.0, -1.0)),
        SKYBLUE,
        0.1,
    );

    // Rectangle
    quad(
        &draw,
        &mid_top,
        (
            pt2(-1.0, 0.5),
            pt2(1.0, 0.5),
            pt2(1.0, -0.5),
            pt2(-1.0, -0.5),
        ),
        SKYBLUE,
        0.1,
    );

    // Circle
    ellipse(&draw, &top_right, 1.0, 1.0, 0.0, SKYBLUE, 0.1);

    // Line with dots
    line(
        &draw,
        &mid_left,
        pt2(-1.0, 1.0),
        pt2(1.0, -1.0),
        pt2(0.5, 0.5),
        pt2(-0.5, -0.5),
        SKYBLUE,
        0.1,
        0.1,
    );

    // Bezier
    let mut builder = Path::builder();
    builder.begin(point(-1.0, 1.0));
    builder.line_to(point(-1.0, -1.0));
    builder.cubic_bezier_to(point(-0.75, 1.0), point(0.75, -1.0), point(1.0, 1.0));
    builder.line_to(point(1.0, -1.0));
    builder.end(false);
    path(&draw, &center, builder.build(), SKYBLUE, 0.1);

    // Polyline
    polyline(
        &draw,
        &mid_right,
        vec![
            pt2(-1.0, 0.0),
            pt2(-0.5, -1.0),
            pt2(-0.5, 1.0),
            pt2(0.5, -1.0),
            pt2(0.5, 1.0),
            pt2(1.0, 0.0),
        ],
        SKYBLUE,
        0.1,
    );

    // Arc
    arc(&draw, &bottom_left, 1.0, PI * 0.25, PI * 1.5, SKYBLUE, 0.1);

    // Quad
    quad(&draw, &mid_bottom, (pt2(-1.0, 1.0), pt2(0.25, 1.0), pt2(1.0, -1.0), pt2(-1.0, -1.0)), SKYBLUE, 0.1);

    // Ellipse
    ellipse(&draw, &bottom_right,0.5, 1.0, PI * 0.25, SKYBLUE, 0.1);

    draw.to_frame(app, &frame).unwrap();
}

fn tri<C>(
    draw: &Draw,
    rect: &Rect,
    points_normed: (Point2, Point2, Point2),
    color: C,
    stroke_weight_normed: f32,
) where
    C: IntoLinSrgba<ColorScalar>,
{
    let stroke_weight = denorm_f32(rect, stroke_weight_normed);
    let rect_inner = rect.pad(stroke_weight / 2.0);

    let (an, bn, cn) = points_normed;
    let (a, b, c) = tuple_map!((an, bn, cn), x, denorm_pt(&rect_inner, x));

    let opts = StrokeOptions::default().with_line_join(LineJoin::Round);

    draw.tri()
        .no_fill()
        .stroke_opts(opts)
        .stroke_color(color)
        .stroke_weight(stroke_weight)
        .points(a, b, c);
}

fn quad<C>(
    draw: &Draw,
    rect: &Rect,
    points_normed: (Point2, Point2, Point2, Point2),
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

fn ellipse<C>(
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
    let stroke_weight = denorm_f32(rect, stroke_weight_normed);
    let rect_inner = rect.pad(stroke_weight / 2.0);

    let (w, h) = ratio_to_wh(&rect_inner, width_ratio, height_ratio);

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

fn line<C>(
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
    let stroke_weight = denorm_f32(rect, stroke_weight_normed);
    let dot_size = denorm_f32(rect, dot_size_normed);

    let rect_inner = rect.pad(stroke_weight / 2.0);

    let start = denorm_pt(&rect_inner, start_normed);
    let end = denorm_pt(&rect_inner, end_normed);
    let dot1 = denorm_pt(&rect_inner, dot1_normed);
    let dot2 = denorm_pt(&rect_inner, dot2_normed);

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

fn path<C>(draw: &Draw, rect: &Rect, path_normed: Path, color: C, stroke_weight_normed: f32)
where
    C: IntoLinSrgba<ColorScalar>,
{
    let stroke_weight = denorm_f32(rect, stroke_weight_normed);
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
        let v = denorm_pt(&self.rect, pt2(p.x, p.y));
        point(v.x, v.y)
    }
    fn transform_vector(&self, p: Vector) -> Vector {
        let v = denorm_pt(&self.rect, pt2(p.x, p.y));
        vector(v.x, v.y)
    }
}

fn polyline<C>(
    draw: &Draw,
    rect: &Rect,
    points_normed: Vec<Point2>,
    color: C,
    stroke_weight_normed: f32,
) where
    C: IntoLinSrgba<ColorScalar>,
{
    let stroke_weight = denorm_f32(rect, stroke_weight_normed);
    let rect_inner = rect.pad(stroke_weight / 2.0);
    let points = points_normed
        .iter()
        .map(|p| denorm_pt(&rect_inner, p.clone()));
    draw.polyline()
        .color(color)
        .weight(stroke_weight)
        .start_cap_round()
        .end_cap_round()
        .join_round()
        .points(points);
}

fn arc<C>(
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
    let stroke_weight = denorm_f32(rect, stroke_weight_normed);
    let rect_inner = rect.pad(stroke_weight / 2.0);

    let radius = denorm_f32(&rect_inner, radius_normed);

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

fn ratio_to_wh(rect: &Rect, width_ratio: f32, height_ratio: f32) -> (f32, f32) {
    if width_ratio > height_ratio {
        (rect.w(), (rect.w() / width_ratio) * height_ratio)
    } else {
        ((rect.h() / height_ratio) * width_ratio, rect.h())
    }
}

fn denorm_pt(rect: &Rect, point_normed: Point2) -> Point2 {
    let w_half = rect.w() / 2.0;
    let h_half = rect.h() / 2.0;
    let x = rect.x() + w_half * point_normed.x;
    let y = rect.y() + h_half * point_normed.y;
    pt2(x, y)
}

// Denormalize based by shorter side
fn denorm_f32(rect: &Rect, value_normed: f32) -> f32 {
    if rect.w() > rect.h() {
        value_normed * (rect.h() / 2.0)
    } else {
        value_normed * (rect.w() / 2.0)
    }
}
