(module
	(import "memory" "main" (memory $main 1))
	(import "memory" "mat4" (memory $mat4 1))

	(func $log (import "console" "log") (param f32))

	;; trig functions
	(func $sin (import "Math" "sin") (param f32) (result f32))
	(func $cos (import "Math" "cos") (param f32) (result f32))
	(func $tan (import "Math" "tan") (param f32) (result f32))
	(func $asin (import "Math" "asin") (param f32) (result f32))
	(func $acos (import "Math" "acos") (param f32) (result f32))
	(func $atan (import "Math" "atan") (param f32) (result f32))
	(func $atan2 (import "Math" "atan2") (param f32 f32) (result f32))

	;; identity matrix
	(func $mat4id (export "mat4id") (param $out i32)
		(v128.store offset=0  (local.get $out) (v128.const f32x4 1 0 0 0))
		(v128.store offset=16 (local.get $out) (v128.const f32x4 0 1 0 0))
		(v128.store offset=32 (local.get $out) (v128.const f32x4 0 0 1 0))
		(v128.store offset=48 (local.get $out) (v128.const f32x4 0 0 0 1))
	)

	;; transpose
	(func $mat4xpose (export "mat4xpose") (param $m i32) (param $out i32)
		(local $m01 f32)
		(local $m02 f32)
		(local $m03 f32)
		(local $m10 f32)
		(local $m12 f32)
		(local $m13 f32)
		(local $m20 f32)
		(local $m21 f32)
		(local $m23 f32)
		(local $m30 f32)
		(local $m31 f32)
		(local $m32 f32)

		;; load input into tmp vars
		(local.set $m01 (f32.load offset=4  (local.get $m)))
		(local.set $m02 (f32.load offset=8  (local.get $m)))
		(local.set $m03 (f32.load offset=12 (local.get $m)))
		(local.set $m10 (f32.load offset=16 (local.get $m)))
		(local.set $m12 (f32.load offset=24 (local.get $m)))
		(local.set $m13 (f32.load offset=28 (local.get $m)))
		(local.set $m20 (f32.load offset=32 (local.get $m)))
		(local.set $m21 (f32.load offset=36 (local.get $m)))
		(local.set $m23 (f32.load offset=44 (local.get $m)))
		(local.set $m30 (f32.load offset=48 (local.get $m)))
		(local.set $m31 (f32.load offset=52 (local.get $m)))
		(local.set $m32 (f32.load offset=56 (local.get $m)))

		;; store transposed indices
		(f32.store offset=4  (local.get $out) (local.get $m10))
		(f32.store offset=8  (local.get $out) (local.get $m20))
		(f32.store offset=12 (local.get $out) (local.get $m30))
		(f32.store offset=16 (local.get $out) (local.get $m01))
		(f32.store offset=24 (local.get $out) (local.get $m21))
		(f32.store offset=28 (local.get $out) (local.get $m31))
		(f32.store offset=32 (local.get $out) (local.get $m02))
		(f32.store offset=36 (local.get $out) (local.get $m12))
		(f32.store offset=44 (local.get $out) (local.get $m32))
		(f32.store offset=48 (local.get $out) (local.get $m03))
		(f32.store offset=52 (local.get $out) (local.get $m13))
		(f32.store offset=56 (local.get $out) (local.get $m23))

		;; if src != dst, copy diagonal
		(if (i32.ne (local.get $m) (local.get $out)) (then
			(f32.store offset=0  (local.get $out) (f32.load offset=0  (local.get $m)))
			(f32.store offset=20 (local.get $out) (f32.load offset=20 (local.get $m)))
			(f32.store offset=40 (local.get $out) (f32.load offset=40 (local.get $m)))
			(f32.store offset=60 (local.get $out) (f32.load offset=60 (local.get $m)))
		))
	)

	(func $mat4add (export "mat4add") (param $a i32) (param $b i32) (param $out i32)
		(v128.store (local.get $out)
			(f32x4.add (v128.load (local.get $a)) (v128.load (local.get $b)))
		)

		(v128.store offset=16 (local.get $out)
			(f32x4.add (v128.load offset=16 (local.get $a)) (v128.load offset=16 (local.get $b)))
		)

		(v128.store offset=32 (local.get $out)
			(f32x4.add (v128.load offset=32 (local.get $a)) (v128.load offset=32 (local.get $b)))
		)

		(v128.store offset=48 (local.get $out)
			(f32x4.add (v128.load offset=48 (local.get $a)) (v128.load offset=48 (local.get $b)))
		)
	)

	(func $mat4sub (export "mat4sub") (param $a i32) (param $b i32) (param $out i32)
		(v128.store (local.get $out)
			(f32x4.sub (v128.load (local.get $a)) (v128.load (local.get $b)))
		)

		(v128.store offset=16 (local.get $out)
			(f32x4.sub (v128.load offset=16 (local.get $a)) (v128.load offset=16 (local.get $b)))
		)

		(v128.store offset=32 (local.get $out)
			(f32x4.sub (v128.load offset=32 (local.get $a)) (v128.load offset=32 (local.get $b)))
		)

		(v128.store offset=48 (local.get $out)
			(f32x4.sub (v128.load offset=48 (local.get $a)) (v128.load offset=48 (local.get $b)))
		)
	)

	;; mat4mul helper
	(func $mrow (param $p v128) (param $r0 v128) (param $r1 v128) (param $r2 v128) (param $r3 v128) (result v128)
		(f32x4.add
			(f32x4.add
				(f32x4.mul (f32x4.splat (f32x4.extract_lane 0 (local.get $p))) (local.get $r0))
				(f32x4.mul (f32x4.splat (f32x4.extract_lane 1 (local.get $p))) (local.get $r1))
			)
			(f32x4.add
				(f32x4.mul (f32x4.splat (f32x4.extract_lane 2 (local.get $p))) (local.get $r2))
				(f32x4.mul (f32x4.splat (f32x4.extract_lane 3 (local.get $p))) (local.get $r3))
			)
		)
	)

	;; a: LHS (ptr), b: RHS (ptr), out: output (ptr)
	(func $mat4mul (export "mat4mul") (param $a i32) (param $b i32) (param $out i32)
		(local $r0 v128)
		(local $r1 v128)
		(local $r2 v128)
		(local $r3 v128)

		(v128.store (local.get $out)
			(call $mrow
				(v128.load (local.get $b))
				(local.tee $r0 (v128.load offset=0  (local.get $a)))
				(local.tee $r1 (v128.load offset=16 (local.get $a)))
				(local.tee $r2 (v128.load offset=32 (local.get $a)))
				(local.tee $r3 (v128.load offset=48 (local.get $a)))
			)
		)

		(v128.store offset=16 (local.get $out)
			(call $mrow
				(v128.load offset=16 (local.get $b))
				(local.get $r0) (local.get $r1) (local.get $r2) (local.get $r3)
			)
		)

		(v128.store offset=32 (local.get $out)
			(call $mrow
				(v128.load offset=32 (local.get $b))
				(local.get $r0) (local.get $r1) (local.get $r2) (local.get $r3)
			)
		)

		(v128.store offset=48 (local.get $out)
			(call $mrow
				(v128.load offset=48 (local.get $b))
				(local.get $r0) (local.get $r1) (local.get $r2) (local.get $r3)
			)
		)
	)

	(func $mat4trs (export "mat4trs") (param $t i32) (param $r i32) (param $s i32) (param $out i32)
		(local $sx f32)
		(local $sy f32)
		(local $sz f32)
		(local $qx f32)
		(local $qy f32)
		(local $qz f32)
		(local $qw f32)

		(local $xx f32)
		(local $xy f32)
		(local $xz f32)
		(local $yy f32)
		(local $yz f32)
		(local $zz f32)
		(local $wx f32)
		(local $wy f32)
		(local $wz f32)
		(local $x2 f32)
		(local $y2 f32)
		(local $z2 f32)

		(local.set $sx (f32.load offset=4  (local.get $s)))
		(local.set $sy (f32.load offset=8  (local.get $s)))
		(local.set $sz (f32.load offset=12 (local.get $s)))

		(local.set $qx (f32.load offset=4  (local.get $r)))
		(local.set $qy (f32.load offset=8  (local.get $r)))
		(local.set $qz (f32.load offset=12 (local.get $r)))
		(local.set $qw (f32.load offset=16 (local.get $r)))

		;; out[0] = sx * (1 - (yy + zz))
		(f32.store (local.get $out)
			(f32.mul (local.get $sx)
				(f32.sub (f32.const 1)
					(f32.add
						;; yy = qy * y2
						(local.tee $yy (f32.mul (local.get $qy)
							;; y2 = qy + qy
							(local.tee $y2 (f32.add (local.get $qy) (local.get $qy)))
						))
						;; zz = qz * z2
						(local.tee $zz (f32.mul (local.get $qz)
							;; z2 = qz + qz
							(local.tee $z2 (f32.add (local.get $qz) (local.get $qz)))
						))
					)
				)
			)
		)

		;; out[1] = sx * (xy + wz)
		(f32.store offset=4 (local.get $out)
			(f32.mul (local.get $sx)
				(f32.add
					;; xy = qx * y2
					(local.tee $xy (f32.mul (local.get $qx) (local.get $y2)))
					;; wz = qw * z2
					(local.tee $wz (f32.mul (local.get $qw) (local.get $z2)))
				)
			)
		)

		;; out[2] = sx * (xz - wy)
		(f32.store offset=8 (local.get $out)
			(f32.mul (local.get $sx)
				(f32.sub
					;; xz = qx * z2
					(local.tee $xz (f32.mul (local.get $qx) (local.get $z2)))
					;; wy = qw * y2
					(local.tee $wy (f32.mul (local.get $qw) (local.get $y2)))
				)
			)
		)

		;; out[3] = 0
		(f32.store offset=12 (local.get $out) (f32.const 0))

		;; out[4] = sy * (xy - wz)
		(f32.store offset=16 (local.get $out)
			(f32.mul (local.get $sy) (f32.sub (local.get $xy) (local.get $wz)))
		)

		;; out[5] = sy * (1 - (xx + zz))
		(f32.store offset=20 (local.get $out)
			(f32.mul (local.get $sy)
				(f32.sub (f32.const 1)
					(f32.add
						;; xx = qx * x2
						(local.tee $xx (f32.mul (local.get $qx)
							;; x2 = qx + qx
							(local.tee $x2 (f32.add (local.get $qx) (local.get $qx)))
						))
						(local.get $zz)
					)
				)
			)
		)

		;; out[6] = sy * (yz + wx)
		(f32.store offset=24 (local.get $out)
			(f32.mul (local.get $sy)
				(f32.add
					;; yz = qy * z2
					(local.tee $yz (f32.mul (local.get $qy) (local.get $z2)))
					;; wx = qw * x2
					(local.tee $wx (f32.mul (local.get $qw) (local.get $x2)))
				)
			)
		)

		;; out[7] = 0
		(f32.store offset=28 (local.get $out) (f32.const 0))

		;; out[8] = sz * (xz + wy)
		(f32.store offset=32 (local.get $out)
			(f32.mul (local.get $sz) (f32.add (local.get $xz) (local.get $wy)))
		)

		;; out[9] = sz * (yz - wx)
		(f32.store offset=36 (local.get $out)
			(f32.mul (local.get $sz) (f32.sub (local.get $yz) (local.get $wx)))
		)

		;; out[10] = sz * (1 - (xx + yy))
		(f32.store offset=40 (local.get $out)
			(f32.mul (local.get $sz) (f32.sub (f32.const 1) (f32.add (local.get $xx) (local.get $yy))))
		)

		;; out[11] = 0
		(f32.store offset=44 (local.get $out) (f32.const 0))

		;; out[12] = t[0]; out[13] = t[1]; out[14] = t[2];
		(f32.store offset=48 (local.get $out) (f32.load offset=0 (local.get $t)))
		(f32.store offset=52 (local.get $out) (f32.load offset=4 (local.get $t)))
		(f32.store offset=56 (local.get $out) (f32.load offset=8 (local.get $t)))

		;; out[15] = 1
		(f32.store offset=60 (local.get $out) (f32.const 1))
	)
)