use nannou::{
    noise::{NoiseFn, Perlin},
    prelude::*,
};

pub struct Line {
    center_x: f32,
    center_y: f32,
    length: f32,
    angle: f64,
    angle_step: f64,
    hues: [f32; 3],
    hue_index: usize,
    x_noise_factor: f64,
    y_noise_factor: f64,
}

impl Line {
    pub fn new(
        center_x: f32,
        center_y: f32,
        length: f32,
        angle: f64,
        angle_step: f64,
        base_hue: f32,
    ) -> Line {
        Line {
            center_x,
            center_y,
            length,
            angle,
            angle_step,
            hues: [base_hue - 30.0, base_hue, base_hue + 30.0],
            hue_index: 0,
            x_noise_factor: random_f64(),
            y_noise_factor: random_f64(),
        }
    }

    pub fn update(&mut self) {
        self.update_center_xy();
        self.update_angle();
        self.update_hue();
        self.update_noise_factor();
    }

    pub fn show(&self, draw: &Draw) {
        let adj = self.length / 2.0;
        let cos = self.angle.to_radians().cos() as f32;
        let sin = self.angle.to_radians().sin() as f32;
        let start = pt2(
            self.center_x + cos * adj,
            self.center_y + sin * adj,
        );
        let end = pt2(
            self.center_x - cos * adj,
            self.center_y - sin * adj,
        );
        draw.line()
            .start(start)
            .end(end)
            .hsva(self.hue() / 360.0, 0.9, 0.9, 0.1);
    }

    fn hue(&self) -> f32 {
        self.hues[self.hue_index]
    }

    fn update_center_xy(&mut self) {
        let perlin = Perlin::new();
        let x_noise = perlin.get([self.x_noise_factor, 0.0]) as f32;
        let y_noise = perlin.get([self.y_noise_factor, 0.0]) as f32;
        self.center_x += x_noise;
        self.center_y += y_noise;
    }

    fn update_angle(&mut self) {
        self.angle += self.angle_step;
    }

    fn update_hue(&mut self) {
        self.hue_index += 1;
        if self.hue_index >= self.hues.len() {
            self.hue_index -= self.hues.len();
        }
    }

    fn update_noise_factor(&mut self) {
        self.x_noise_factor += 0.005;
        self.y_noise_factor += 0.005;
    }
}
