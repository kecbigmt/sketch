use nannou::prelude::*;

mod util;

fn main() {
    nannou::sketch(view).run();
}

fn view(app: &App, frame: Frame) {
    let draw = app.draw();
    draw.background().color(WHITE);

    let win = app.window_rect();

    // K
    util::line(&draw, &win, pt2(-0.75, 0.6), pt2(-0.75, -0.6), SKYBLUE, 0.06);
    util::tri(&draw, &win, (pt2(-0.65, 0.0), pt2(-0.6, 0.05), pt2(-0.6, -0.05)),  SKYBLUE);
    util::line(&draw, &win, pt2(-0.5, 0.1), pt2(-0.5, -0.1), SKYBLUE, 0.03);
    util::line(&draw, &win, pt2(-0.4, 0.2), pt2(-0.4, -0.2), SKYBLUE, 0.04);
    util::line(&draw, &win, pt2(-0.3, 0.3), pt2(-0.3, -0.3), SKYBLUE, 0.05);
    util::line(&draw, &win, pt2(-0.175, 0.6), pt2(-0.175, -0.6), SKYBLUE, 0.06);

    // O
    util::arc(&draw, &win, pt2(0.3875, 0.0125), 0.5, PI * 0.25, PI, SKYBLUE, true, false, 0.03);
    util::arc(&draw, &win, pt2(0.3875, 0.0125), 0.3, PI * 0.25, PI, SKYBLUE, true, false, 0.02);
    util::arc(&draw, &win, pt2(0.3875, 0.0125), 0.1, PI * 0.25, PI, SKYBLUE, false, true, 0.0);
    util::arc(&draw, &win, pt2(0.4125, -0.0125), 0.4, PI * 1.25, PI, SKYBLUE, false, true, 0.0);
    util::arc(&draw, &win, pt2(0.4125, -0.0125), 0.6, PI * 1.25, PI, SKYBLUE, true, false, 0.05);

    draw.to_frame(app, &frame).unwrap();

    let path = format!("./{:04}.png", frame.nth());
    app.main_window().capture_frame(path.as_str());
}