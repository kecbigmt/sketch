import { mat4 } from "gl-matrix";

const vert = `
  attribute vec3 position;
  uniform mat4 mvpMatrix;

  void main(void) {
    gl_Position = mvpMatrix * vec4(position, 1.0);
  }
`;

const frag = `
  void main(void) {
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
  }
`;

/*
1. HTML から canvas エレメントを取得
2. canvas から WebGL コンテキストの取得
3. シェーダのコンパイル
4. モデルデータを用意
5. 頂点バッファ( VBO )の生成と通知
6. 座標変換行列の生成と通知
7. 描画命令の発行
8. canvas を更新してレンダリング
*/

function main() {
  const canvas = document.getElementById("canvas") as HTMLCanvasElement;
  canvas.width = 300;
  canvas.height = 300;

  const gl = canvas.getContext("webgl");
  if (!gl) throw new Error("failed to get webgl rendering context");

  gl.clearColor(0.0, 0.0, 0.0, 1.0);
  gl.clearDepth(1.0);

  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

  const draw = new Draw(gl);
  const vs = draw.createShader(gl.VERTEX_SHADER, vert);
  const fs = draw.createShader(gl.FRAGMENT_SHADER, frag);
  const program = draw.createProgram(vs, fs);

  const attLocation = gl.getAttribLocation(program, "position");
  const attStride = 3; // attributeの要素数（この場合はxyzの３要素）
  // モデル（頂点）データ
  const vertexPosition = [
    0.0, 1.0, 0.0,
    1.0, 0.0, 0.0,
    -1.0, 0.0, 0.0,
  ];

  const vbo = draw.createVertexBufferObject(vertexPosition);
  gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
  gl.enableVertexAttribArray(attLocation); // attribute属性を有効にする
  
  // バインドされたデータをattribute属性として登録
  gl.vertexAttribPointer(attLocation, attStride, gl.FLOAT, false, 0, 0); 

  // モデル座標変換行列
  const mMatrix = mat4.create();
  mat4.identity(mMatrix);

  // ビュ＝座標変換行列
  const vMatrix = mat4.create();
  const eye = new Float32Array([0.0, 1.0, 3.0]); // カメラの位置
  const center = new Float32Array([0, 0, 0]); // カメラの注視点
  const up = new Float32Array([0, 1, 0]); // カメラの上方向はy軸方向
  mat4.lookAt(vMatrix, eye, center, up);

  // プロジェクション座標変換行列
  const pMatrix = mat4.create();
  const fieldOfView = 90 * Math.PI / 180; // 視野角90度
  const aspect = canvas.width / canvas.height; // アスペクト比をcanvasのサイズと一致させる
  const zNear = 0.1;
  const zFar = 100;
  mat4.perspective(pMatrix, fieldOfView, aspect, zNear, zFar);

  // 各行列を掛け合わせ、座標変換行列を作る
  const mvpMatrix = mat4.create();
  mat4.multiply(mvpMatrix, pMatrix, vMatrix);
  mat4.multiply(mvpMatrix, mvpMatrix, mMatrix);

  // uniformLocationを取得して、座標変換行列を登録する
  const uniLocation = gl.getUniformLocation(program, "mvpMatrix");
  gl.uniformMatrix4fv(uniLocation, false, mvpMatrix);

  // モデルの描画
  gl.drawArrays(gl.TRIANGLES, 0, 3);

  // コンテキストの際描画
  gl.flush();
}

class Draw {
  gl: WebGLRenderingContext;

  constructor(gl: WebGLRenderingContext) {
    this.gl = gl;
  }

  createShader(type: number, source: string): WebGLShader {
    const shader = this.gl.createShader(type);
    if (!shader) throw new Error("failed to create webgl shader");

    this.gl.shaderSource(shader, source);
    this.gl.compileShader(shader);
    if (this.gl.getShaderParameter(shader, this.gl.COMPILE_STATUS)) {
      return shader;
    }
    throw new Error("failed to create shader: " + this.gl.getShaderInfoLog(shader));
  } 

  createProgram(vs: WebGLShader, fs: WebGLShader) {
    const program = this.gl.createProgram();
    if (!program) throw new Error("failed to create webgl program");

    this.gl.attachShader(program, vs);
    this.gl.attachShader(program, fs);

    this.gl.linkProgram(program);

    if (this.gl.getProgramParameter(program, this.gl.LINK_STATUS)) {
      this.gl.useProgram(program);
      return program;
    }

    throw new Error("failed to link program: " + this.gl.getProgramInfoLog(program));
  }

  createVertexBufferObject(data: number[]): WebGLBuffer {
    const vbo = this.gl.createBuffer(); // バッファを生成する
    if (!vbo) throw new Error("failed to create webgl buffer");

    this.gl.bindBuffer(this.gl.ARRAY_BUFFER, vbo); // WebGLにバッファをバインドする
    this.gl.bufferData(
      this.gl.ARRAY_BUFFER,
      new Float32Array(data), // 浮動小数点を扱う型付オブジェクト
      this.gl.STATIC_DRAW, // そのバッファがどのような頻度で内容を更新されるのか定義。VBOの場合はモデルデータをそのまま何度も利用するためこれを使う
    );
    this.gl.bindBuffer(this.gl.ARRAY_BUFFER, null); // WebGLからバッファを外す
    return vbo;
  }
}

window.onload = main;