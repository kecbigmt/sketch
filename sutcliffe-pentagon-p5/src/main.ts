import p5, { Renderer } from "p5";
import { Point, Branch } from "./lib";

const NUM_SIDES = 8;
let strutNoise = 0; 
let canvas: Renderer;

const sketch = (p: p5) => {
  const drawBranch = (b: Branch) => {
    p.strokeWeight(5 - b.level);
    for (let i = 0; i < b.outerPoints.length; i++) {
      const current = b.outerPoints[i];
      const next = b.outerPoints[i+1 === b.outerPoints.length ? 0 : i+1];
      p.line(current.x, current.y, next.x, next.y);
    }
    if (b.children.length > 0) {
      b.midPoints.forEach((mp, i) => {
        p.strokeWeight(0.5);
        const sp = b.projPoints[i];
        p.line(mp.x, mp.y, sp.x, sp.y);
        // p.ellipse(mp.x, mp.y, 10, 10);
        // p.ellipse(sp.x, sp.y, 10, 10);
      });
      for (let child of b.children) {
        drawBranch(child);
      }
    }
  };

  p.setup = () => {
    canvas = p.createCanvas(1000, 1000);
    p.frameRate(30);
  };

  p.draw = () => {
    p.background(255);
    p.ellipse(p.mouseX, p.mouseY, 10, 10);

    strutNoise += 0.01;
    const strutFactor = p.noise(strutNoise) * 3 - 1;

    const outerPoints: Point[] = [];
    for (let i = 0; i < 360; i += 360 / NUM_SIDES) {
      const deg = p.frameCount + i;
      outerPoints.push({
        x: p.width / 2 + (400 * Math.cos(deg * (Math.PI / 180))),
        y: p.height / 2 + (400 * Math.sin(deg * (Math.PI / 180))),
      });
    }
    const rootBranch = new Branch(0, 0, strutFactor, outerPoints);

    drawBranch(rootBranch);
  }

  p.keyPressed = (e) => {
    if (p.keyCode === p.ENTER) {
        p.saveCanvas(canvas, `frame_${p.frameCount}`, "png");
    }
  };
};

new p5(sketch);