import std/[strformat]

proc `===`(title: string) =
  echo fmt"--{title:-<30}"

template echoAddr(v: untyped; tag: static[string]) =
  block:
    let t {.inject.} = tag
    let vv {.inject.} = cast[int](v)
    echo fmt"{t:<30}: {vv}"

proc testImmutCopy[T](a: T) =
  echoAddr a.addr, "immut copy var"
  when a is ref:
    echoAddr a, "immut copy var ->"
  when a is array:
    echoAddr a[0].addr, "immut copy var elements"
  when a is seq:
    echoAddr a[0].addr, "immut copy var elements"
  when a is string:
    echoAddr a[0].addr, "immut copy var elements"

proc testMutBorrow[T](a: var T) =
  echoAddr a.addr, "mut borrow var"
  when a is ref:
    echoAddr a, "mut borrow var ->"
  when a is array:
    echoAddr a[0].addr, "mut borrow var elements"
  when a is seq:
    echoAddr a[0].addr, "mut borrow var elements"
  when a is string:
    echoAddr a[0].addr, "mut borrow var elements"

proc testPtr[T](a: ptr T) =
  echoAddr a.addr, "ptr var"
  echoAddr a, "ptr var ->"
  when a[] is ref:
    echoAddr a[], "ptr var -> ->"
  when a[] is array:
    echoAddr a[][0].addr, "ptr var -> elements"
  when a[] is seq:
    echoAddr a[][0].addr, "ptr var -> elements"
  when a[] is string:
    echoAddr a[][0].addr, "ptr var -> elements"

proc testMoveOrCopy[T](a: sink T) =
  echoAddr a.addr, "move or copy var"
  when a is ref:
    echoAddr a, "move or copy var ->"
  when a is array:
    echoAddr a[0].addr, "move or copy var elements"
  when a is seq:
    echoAddr a[0].addr, "move or copy var elements"
  when a is string:
    echoAddr a[0].addr, "move or copy var elements"

template echoAddrs(a, T: untyped) =
  echoAddr a.addr, "origin var"
  when a is ref:
    echoAddr a, "origin var ->"
  when a is array:
    echoAddr a[0].addr, "origin var elements"
  when a is seq:
    echoAddr a[0].addr, "origin var elements"
  when a is string:
    echoAddr a[0].addr, "origin var elements"
  testImmutCopy[T](a)
  testMutBorrow[T](a)
  testMoveOrCopy[T](a)
  testPtr[T](addr(a))

==="value object"
type P = object
  name: string
  age: int

var a = P(name: "foo", age: 10)
echoAddrs a, P

==="ref object"
type Pr = ref P
var b = Pr(name: "foo", age: 10)
echoAddrs b, Pr

==="seq"
var c = @["foo", "bar"]
echoAddrs c, seq[string]

==="array"
var d = ["foo", "bar"]
echoAddrs d, array[2, string]

==="string"
var e = "foo"
e.add "bar"
echoAddrs e, string
