import p5 from 'p5';

const sketch = (p: p5) => {
  p.setup = () => {
    p.createCanvas(p.windowWidth, p.windowHeight);
    p.background(100);
  };

  p.draw = () => {
    p.circle(p.mouseX, p.mouseY, 20);
  };
};

new p5(sketch);
