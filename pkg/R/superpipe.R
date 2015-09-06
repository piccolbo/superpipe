`%~>%` =
superpipe =
  function(left, right) {
    asFunction(right)(left)}

Range = function(x) structure(x, class = c("Range", class(x)))
Row = function(x) structure(x, class = c("Row", class(x)))
Col = function(x) structure(x, class = c("Col", class(x)))

asFunction = function(right, range) UseMethod("asFunction")

asFunction.function = function(right, range) right

asFunction.formula =
  function(right, range = NULL) {
    function(left) {
      eval(
        as.list(right)[[2]],
        c(list(.. = left), as.list(left)),
        environment(right))}}

asFunction.default =
  function(right) {
    row.range.selector = function(left) left[right, , drop = FALSE]
    range.selector = function(left) left[right]
    row.selector = function(left) left[right, , drop = TRUE]
    selector = function(left) left[[right]]
    if(inherits(right, "Range")) {
      if(inherits(right, "Row")) {
        row.range.selector}
      else {
        range.selector }}
    else {
      if(inherits(right, "Row")) {
        row.selector}
      else {
        selector}}}


`%@>%`=
map =
  function(left, right) {
    mapfun(left, partial(superpipe, right = right))}

mapfun = function(x, fun) UseMethod("mapfun")

mapfun.default =
  function(x, fun)
    lapply(x, fun)

