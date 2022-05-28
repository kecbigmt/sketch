const MAX_LEVEL = 4;

export type Point = {
  x: number;
  y: number;
};

export class FractalRoot {
  rootBranch: Branch;

  constructor(centX: number, centY: number, strutFactor: number) {
    const outerPoints: Point[] = [];
    for (let deg = 0; deg < 360; deg += 72) {
      outerPoints.push({
        x: centX + (400 * Math.cos(deg * (Math.PI / 180))),
        y: centY + (400 * Math.sin(deg * (Math.PI / 180))),
      });
    }
    this.rootBranch = new Branch(0, 0, strutFactor, outerPoints);
  }
}

export class Branch {
  level: number;
  n: number;
  outerPoints: Point[];
  midPoints: Point[];
  projPoints: Point[];
  children: Branch[];
  strutFactor: number;

  constructor(level: number, n: number, strutFactor: number, outerPoints: Point[]) {
    this.level = level;
    this.n = n;
    this.strutFactor = strutFactor;
    this.outerPoints = outerPoints;
    this.midPoints = this.calcMidPoints();
    this.projPoints = this.calcStrutPoints();
    this.children = [];
    if (level+1 <= MAX_LEVEL) {
      this.children.push(new Branch(level+1, n+1, strutFactor, this.projPoints));
      for (let k = 0; k < this.outerPoints.length; k++) {
        const nextk = k-1 >= 0 ? k-1 : k-1 + this.outerPoints.length;
        const points = [this.projPoints[k], this.midPoints[k], this.outerPoints[k], this.midPoints[nextk], this.projPoints[nextk]];
        this.children.push(new Branch(level+1, n+1, strutFactor, points));
      }
    }
  }

  private calcMidPoints(): Point[] {
    const midPoints: Point[] = [];
    for (let i = 0; i < this.outerPoints.length; i++) {
      const current = this.outerPoints[i];
      const next = this.outerPoints[i+1 === this.outerPoints.length ? 0 : i+1];
      midPoints.push(Branch.calcMidPoint(current, next));
    }
    return midPoints;
  }

  private static calcMidPoint(p1: Point, p2: Point): Point {
    const x = p1.x > p2.x ? p2.x + (p1.x - p2.x) / 2 : p1.x + (p2.x - p1.x) / 2;
    const y = p1.y > p2.y ? p2.y + (p1.y - p2.y) / 2 : p1.y + (p2.y - p1.y) / 2;
    return { x, y };
  }

  private calcStrutPoints(): Point[] {
    const strutPoints: Point[] = [];
    for (let i = 0; i < this.midPoints.length; i++) {
      const mp = this.midPoints[i];
      const op = this.outerPoints[i+3 >= this.outerPoints.length ? i+3 - this.outerPoints.length : i+3];
      strutPoints.push(Branch.calcProjPoint(mp, op, this.strutFactor));
    }
    return strutPoints;
  }

  private static calcProjPoint(mp: Point, op: Point, strutFactor: number): Point {
    const opp = mp.x > op.x ? mp.x - op.x : op.x - mp.x;
    const adj = mp.y > op.y ? mp.y - op.y : op.y - mp.y;
    return {
      x: op.x > mp.x ? mp.x + opp * strutFactor : mp.x - opp * strutFactor,
      y: op.y > mp.y ? mp.y + adj * strutFactor : mp.y - adj * strutFactor,
    }
  };
}