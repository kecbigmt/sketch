use nannou::prelude::*;

mod shape;

fn main() {
    nannou::app(model).update(update).view(view).run();
}

struct Model {
    stop: bool,
    line1: shape::Line,
    line2: shape::Line,
}

fn model(app: &App) -> Model {
    app.new_window()
        .size(800, 800)
        .mouse_pressed(mouse_pressed)
        .build()
        .unwrap();

    let base_hue = random_range(0.0, 360.0);
    let angle = random_range(0.0, 360.0);
    let angle_step = 60.0 / 30.0 / 30.0;

    let line1 = shape::Line::new(0.0, 0.0, 800.0, angle, angle_step, base_hue);
    let line2 = shape::Line::new(0.0, 0.0, 800.0, angle + 30.0, angle_step, base_hue + 60.0);

    Model { stop: false, line1, line2 }
}

fn update(_app: &App, model: &mut Model, _update: Update) {
    if model.stop { return };

    model.line1.update();
    model.line2.update();
}

fn mouse_pressed(_app: &App, model: &mut Model, button: MouseButton) {
    if button == MouseButton::Left {
        model.stop = !model.stop;
    }
}

fn view(app: &App, model: &Model, frame: Frame) {
    if model.stop { return };

    let draw = app.draw();
    draw.background();
    
    model.line1.show(&draw);
    model.line2.show(&draw);

    draw.to_frame(app, &frame).unwrap();
}

