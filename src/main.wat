(module
  (tag $err (export "errtag") (param i32))

  ;; basic
  (func (export "add") (param i32 i32) (result i32)
    (i32.add (local.get 0) (local.get 1))
  )

  ;; exceptions
  (func (export "exception")
    (throw $err (i32.const 42))
  )

  ;; multi-return
  (func $divmod (export "divmod") (param $x i32) (param $d i32) (result i32 i32)
    (i32.div_u (local.get $x) (local.get $d))
    (i32.rem_u (local.get $x) (local.get $d))
  )

  ;; flow control (isPrime)
  (func (export "isPrime") (param $n i32) (result i32)
    (local $i i32)
    (local $m i32)

    ;; if (n < 3) return n == 2
    (if (i32.lt_u (local.get $n) (i32.const 3))
      (then (return (i32.eq (local.get $n) (i32.const 2))))
    )

    ;; if (n % 2 == 0) return 0
    (if (i32.eqz (i32.rem_u (local.get $n) (i32.const 2)))
      (then (return (i32.const 0)))
    )

    ;; i = 3
    (local.set $i (i32.const 3))

    ;; m = int(sqrt(float(n)))
    (local.set $m (i32.trunc_f32_u (f32.sqrt (f32.convert_i32_u (local.get $n)))))

    (loop $main
      ;; if (n % i == 0) return 0
      (if (i32.eqz (i32.rem_u (local.get $n) (local.get $i)))
        (then (return (i32.const 0)))
      )

      ;; i += 2
      (local.set $i (i32.add (local.get $i) (i32.const 2)))

      ;; while (i < m)
      (br_if $main (i32.lt_u (local.get $i) (local.get $m)))
    )

    i32.const 1
  )

  ;; recursion (factorial)
  (func $fac (param $n i64) (result i64)
    ;; if (n < 1) return 1
    (if (i64.lt_u (local.get $n) (i64.const 1))
      (then (return (i64.const 1)))
    )
	  ;; return fac(n - 1) * n
    (i64.mul
      (call $fac (i64.sub (local.get $n) (i64.const 1)))
      (local.get $n)
    )
  )

  ;; wrapper function to cast input
  (func (export "factorial") (param $x i32) (result i64)
    (return_call $fac (i64.extend_i32_u (local.get $x)))
  )

  ;; recursion (fibbonacci)
  (func $fib (export "fibbonacci") (param $n i32) (result i32)
    ;; if (n < 1) return 0
    (if (i32.lt_u (local.get $n) (i32.const 1))
      (then (return (i32.const 0)))
    )

    ;; if (n == 1) return 1
    (if (i32.eq (local.get $n) (i32.const 1))
      (then (return (i32.const 1)))
    )

	  ;; return fib(n - 1) + fib(n - 2)
    (i32.add
      (call $fib (i32.sub (local.get $n) (i32.const 1)))
      (call $fib (i32.sub (local.get $n) (i32.const 2)))
    )
  )
)