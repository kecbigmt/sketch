use nannou::prelude::*;

mod util;

fn main() {
    nannou::sketch(view).run();
}

const STROKE_WEIGHT_NORMED: f32 = 0.05;

fn view(app: &App, frame: Frame) {
    let draw = app.draw();
    draw.background().color(WHITE);

    let win = app.window_rect();
    let base_pad = util::denorm_f32(&win, 0.1);
    let base_size = win.w().min(win.h());
    let base = Rect::from_w_h(base_size, base_size).middle_of(win).pad(base_pad);

    util::quad(&draw, &base, (pt2(-1.0, 1.0), pt2(-0.5, 1.0), pt2(-0.5, 0.5), pt2(-1.0, 0.5)), SKYBLUE, STROKE_WEIGHT_NORMED);

    util::quad(&draw, &base, (pt2(-0.3, 1.0), pt2(1.0, 1.0), pt2(1.0, 0.5), pt2(-0.3, 0.5)), SKYBLUE, STROKE_WEIGHT_NORMED);

    util::quad(&draw, &base, (pt2(-0.75, 0.3), pt2(0.25, 0.3), pt2(0.0, -0.2), pt2(-1.0, -0.2)), SKYBLUE, STROKE_WEIGHT_NORMED);
    
    util::quad(&draw, &base, (pt2(0.5, 0.3), pt2(1.0, 0.3), pt2(0.75, -0.2), pt2(0.25, -0.2)), SKYBLUE, STROKE_WEIGHT_NORMED);
    
    util::quad(&draw, &base, (pt2(-0.8, -0.4), pt2(-0.7, -0.4), pt2(-0.5, -1.0), pt2(-1.0, -1.0)), SKYBLUE, STROKE_WEIGHT_NORMED);

    util::quad(&draw, &base, (pt2(0.0, -0.4), pt2(-0.4, -0.9), pt2(0.0, -0.7), pt2(0.4, -0.9)), SKYBLUE, STROKE_WEIGHT_NORMED);

    util::quad(&draw, &base, (pt2(0.5, -0.4), pt2(0.9, -0.4), pt2(1.0, -1.0), pt2(0.5, -0.8)), SKYBLUE, STROKE_WEIGHT_NORMED);

    draw.to_frame(app, &frame).unwrap();
}
