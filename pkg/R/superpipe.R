superpipe =
  function(left, right, range) {
    as.function(right, range = range)(left)}

`%[%` = partial(superpipe, range = TRUE)
`%[[%` = partial(superpipe, range = FALSE)

as.function = function(right, range) UseMethod("as.function")

as.function.function = function(right, range) right

as.function.formula =
  function(right, range = NULL) {
    function(left) {
      eval(
        as.list(right)[[2]],
        c(list(.. = left), as.list(left)),
        environment(right))}}

as.function.numeric =
  function(right, range) {
    function(left) {
      if(range)
        left[right]
      else
        left[[right]] }}

as.function.character =
  function(right, range) {
    function(left) {
      if(isS4(left)) slot(left, right)
      else {
        if(range)
          left[right]
        else
          left[[right]]}}}


map =
  function(left, right, range, direction = c("rows", "columns")) {
    mapfun(left, as.function(right, range), direction)}

`%@%` =  partial(map, range = FALSE, direction = "rows")
`%@|%` =  partial(map, range = FALSE, direction = "columns")
`%@[%` = partial(map, range = TRUE, direction = "rows")
`%@[|%` = partial(map, range = TRUE, direction = "columns")


mapfun = function(x, fun, direction) UseMethod("mapfun")

mapfun.default =
  function(x, fun, direction = NULL)
    lapply(x, fun)

mapfun.data.frame =
  function(x, fun, direction) {
    if(direction == "columns")
      as.data.frame(lapply(mtcars, fun))
    else
      as.data.frame(stop())}

mapfun.matrix =
  function(x, fun, direction){}


