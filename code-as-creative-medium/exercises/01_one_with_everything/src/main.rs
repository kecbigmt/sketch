use nannou::{lyon::{math::point, path::Path}, prelude::*};

mod draw;

fn main() {
    nannou::sketch(view).run();
}

const PAD_NORMED: f32 = 0.05;

fn view(app: &App, frame: Frame) {
    let draw = app.draw();
    draw.background().color(WHITE);

    let win = app.window_rect();

    let base_pad = draw::util::denorm_f32(&win, PAD_NORMED);
    let base_size = win.w().min(win.h());
    let base = Rect::from_w_h(base_size, base_size)
        .middle_of(win)
        .pad(base_pad);

    let grid_pad = draw::util::denorm_f32(&base, PAD_NORMED);
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
    draw::tri(
        &draw,
        &top_left,
        (pt2(0.0, 1.0), pt2(-1.0, -1.0), pt2(1.0, -1.0)),
        SKYBLUE,
        0.1,
    );

    // Rectangle
    draw::quad(
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
    draw::ellipse(&draw, &top_right, 1.0, 1.0, 0.0, SKYBLUE, 0.1);

    // Line with dots
    draw::line(
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
    let path_normed = builder.build();
    draw::path(&draw, &center, path_normed, SKYBLUE, 0.1);

    // Polyline
    draw::polyline(
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
    draw::arc(&draw, &bottom_left, 1.0, PI * 0.25, PI * 1.5, SKYBLUE, 0.1);

    // Quad
    draw::quad(
        &draw,
        &mid_bottom,
        (
            pt2(-1.0, 1.0),
            pt2(0.25, 1.0),
            pt2(1.0, -1.0),
            pt2(-1.0, -1.0),
        ),
        SKYBLUE,
        0.1,
    );

    // Ellipse
    draw::ellipse(&draw, &bottom_right, 0.5, 1.0, PI * 0.25, SKYBLUE, 0.1);

    draw.to_frame(app, &frame).unwrap();
}
