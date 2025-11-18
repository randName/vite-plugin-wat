(module
  (import "env" "memory" (memory 1))
  (import "env" "log" (func $log (param i32 i32)))

  (func $fac (export "factorial") (param $n f64) (result f64)
    (if (result f64) (f64.lt (local.get $n) (f64.const 1))
			(then (return (f64.const 1)))
			(else (return (f64.mul
					(local.get $n)
					(call $fac (f64.sub (local.get $n) (f64.const 1)))
			)))
    )
	)

	(func (export "divmod") (param $inp i32) (result i32 i32)
		(i32.div_u (local.get $inp) (i32.const 10))
		(i32.rem_u (local.get $inp) (i32.const 10))
	)
)