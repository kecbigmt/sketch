use nannou::prelude::*;

pub fn ratio_to_wh(rect: &Rect, width_ratio: f32, height_ratio: f32) -> (f32, f32) {
  if width_ratio > height_ratio {
      (rect.w(), (rect.w() / width_ratio) * height_ratio)
  } else {
      ((rect.h() / height_ratio) * width_ratio, rect.h())
  }
}

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
