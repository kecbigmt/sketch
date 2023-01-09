import { mat4 } from "gl-matrix";

// const mat4 = glMatrix.mat4;

type ProgramInfo = {
  program: WebGLProgram,
  attribLocations: {
    vertexPosition: number,
    vertexColorAttribute: number,
  },
  uniformLocations: {
    projectionMatrix: WebGLUniformLocation,
    modelViewMatrix: WebGLUniformLocation,
  },
};

type Buffers = {
  position: WebGLBuffer,
  squareVerticesColor: WebGLBuffer,
};

function main() {
  const canvas = document.querySelector("#glCanvas") as HTMLCanvasElement;
  // GLコンテキストを初期化する
  const gl = canvas.getContext("webgl");

  // WebGLが使用可能で動作している場合にのみ続行
  if (gl === null) {
    alert("WebGLを初期化できません。ブラウザまたはマシンが対応していない可能性があります");
    return;
  }

  // 頂点シェーダー
  const vsSource = `
  attribute vec4 aVertexPosition;
  attribute vec4 aVertexColor;
  uniform mat4 uModelViewMatrix;
  uniform mat4 uProjectionMatrix;

  varying lowp vec4 vColor;

  void main() {
    gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
    vColor = aVertexColor;
  }
  `;

  // フラグメントシェーダー
  const fsSource = `
  varying lowp vec4 vColor;
  void main() {
    gl_FragColor = vColor;
  }
  `;

  const shaderProgram = initShaderProgram(gl, vsSource, fsSource);
  const programInfo: ProgramInfo = {
    program: shaderProgram!,
    attribLocations: {
      vertexPosition: gl.getAttribLocation(shaderProgram!, "aVertexPosition")!, // aVertexPositionという変数のインデックス番号を取得する
      vertexColorAttribute: gl.getAttribLocation(shaderProgram!, "aVertexColor")!,
    },
    uniformLocations: {
      projectionMatrix: gl.getUniformLocation(shaderProgram!, "uProjectionMatrix")!,
      modelViewMatrix: gl.getUniformLocation(shaderProgram!, "uModelViewMatrix")!,
    }
  };
  const buffers = initBuffers(gl);

  drawScene(gl, programInfo, buffers);
}

function initShaderProgram(gl: WebGLRenderingContext, vsSource: string, fsSource: string) {
  const vertexShader = loadShader(gl, gl.VERTEX_SHADER, vsSource);
  const fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fsSource);

  const shaderProgram = gl.createProgram();
  gl.attachShader(shaderProgram!, vertexShader!);
  gl.attachShader(shaderProgram!, fragmentShader!);
  gl.linkProgram(shaderProgram!);

  if(!gl.getProgramParameter(shaderProgram!, gl.LINK_STATUS)) {
    alert("Unable to initialize the shader program: " + gl.getProgramInfoLog(shaderProgram!));
    return null;
  }

  return shaderProgram;
}

function loadShader(gl: WebGLRenderingContext, type: number, source: string) {
  const shader = gl.createShader(type);
  gl.shaderSource(shader!, source);
  gl.compileShader(shader!);
  if (!gl.getShaderParameter(shader!, gl.COMPILE_STATUS)) {
    alert("An error occurred compiling the shaders: " + gl.getShaderInfoLog(shader!));
    gl.deleteShader(shader);
    return null;
  }
  return shader;
}

/**
 * @param {any} gl
 */
function initBuffers(gl: WebGLRenderingContext) {
  const positionBuffer = gl.createBuffer();
  // これ以降のバッファ操作を適用する対象としてpositionBufferを指定する
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
  // 四角形の座標を配列に入れておく
  const positions = [
    1.0, 1.0,
    -1.0, 1.0,
    1.0, -1.0,
    -1.0, -1.0,
  ];
  // 座標の配列をWebGLに渡して、シェイプを作る。JavaScriptの配列からFloat32Arrayを作り、それを現在のバッファに格納する
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

  const squareVerticesColorBuffer = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, squareVerticesColorBuffer);
  const colors = [
    1.0, 1.0, 1.0, 1.0,
    1.0, 0.0, 0.0, 1.0,
    0.0, 1.0, 0.0, 1.0,
    0.0, 0.0, 1.0, 1.0,
  ];
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW);

  return {
    position: positionBuffer!,
    squareVerticesColor: squareVerticesColorBuffer!,
  };
}

function drawScene(gl: WebGLRenderingContext, programInfo: ProgramInfo, buffers: Buffers) {
  gl.clearColor(0.0, 0.0, 0.0, 1.0); // 100%不透明の黒色にクリアする
  gl.clearDepth(1.0); // 全てをクリアする
  gl.enable(gl.DEPTH_TEST); // depth testingを有効化
  gl.depthFunc(gl.LEQUAL);

  // 描画を始める前にキャンバスをクリアする
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

  // パースペクティブ行列を作る。パースペクティブ行列は、カメラにおける遠近法による歪みをシミュレートするために使われる特殊な行列
  // カメラの視野は45度で、キャンバスの表示サイズと同じ縦横比を持つ。そしてカメラから0.1〜100unitの範囲内のオブジェクトだけが見えるようにする。
  const fieldOfView = 45 * Math.PI / 180; // 45°のラジアン
  const canvas = gl.canvas as HTMLCanvasElement;
  const aspect = canvas.clientWidth / canvas.clientHeight;
  const zNear = 0.1;
  const zFar = 100.0;

  const projectionMatrix = mat4.create();
  mat4.perspective(projectionMatrix, fieldOfView, aspect, zNear, zFar);

  const modelViewMatrix = mat4.create();
  mat4.translate(modelViewMatrix, modelViewMatrix, [-0.0, 0.0, -6.0]);

  {
    const numComponents = 2;
    const type = gl.FLOAT;
    const normalize = false;
    const stride = 0;
    const offset = 0;
    gl.bindBuffer(gl.ARRAY_BUFFER, buffers.position);
    gl.vertexAttribPointer(
      programInfo.attribLocations.vertexPosition,
      numComponents,
      type,
      normalize,
      stride,
      offset,
    );
    gl.enableVertexAttribArray(programInfo.attribLocations.vertexPosition);
  }

  {
    const numComponents = 4;
    const type = gl.FLOAT;
    const normalize = false;
    const stride = 0;
    const offset = 0;
    gl.bindBuffer(gl.ARRAY_BUFFER, buffers.squareVerticesColor);
    gl.vertexAttribPointer(
      programInfo.attribLocations.vertexColorAttribute,
      numComponents,
      type,
      normalize,
      stride,
      offset,
    );
    gl.enableVertexAttribArray(programInfo.attribLocations.vertexColorAttribute);
  }

  gl.useProgram(programInfo.program);

  gl.uniformMatrix4fv(programInfo.uniformLocations.projectionMatrix, false, projectionMatrix);
  gl.uniformMatrix4fv(programInfo.uniformLocations.modelViewMatrix, false, modelViewMatrix);

  {
    const offset = 0;
    const vertexCount = 4;
    gl.drawArrays(gl.TRIANGLE_STRIP, offset, vertexCount);
  }
}

window.onload = main;