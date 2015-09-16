#SE pipe

asFormula =
  function(x, env) {
    form = eval(call("~", x))
    environment(form) = env
    form}


`%>%` =
  yapo =
  function(left, right) {
    if("formula" %in% class(right)){
      rexpr = as.list(right)[[2]]
      if(is.call(rexpr) && rexpr[[1]] == as.name("%>%")){
        yapo(
          yapo(left, asFormula(rexpr[[2]], environment(right))),
          eval(rexpr[[3]], environment(right)))}
      else
        asFunction(right)(left)}
    else
      asFunction(right)(left)}


asFunction = function(right) UseMethod("asFunction")

asFunction.function = function(right) right

setAs("ANY", "data.frame", function(from) as.data.frame(from))

Range = function(x) structure(x, class = c("Range", class(x)))
Row = function(x) structure(x, class = c("Row", class(x)))
Col = function(x) structure(x, class = c("Col", class(x)))

asFunction.formula =
  function(right) {
    rexpr = as.list(right)[[2]]
    if("call" %in% class(rexpr) &&
       !(".." %in% all.vars(rexpr)))
      rexpr =
        as.call(
          c(
            list(
              rexpr[[1]],
              quote(..)),
            as.list(rexpr)[-1]))
    function(left) {
      retval =
        eval(
          rexpr,
          c(list(.. = left), as.list(left)),
          environment(right))
      if(inherits(right, "Range"))
        as(retval, class(left))
      else
        retval}}

asFunction.default =
  function(right) {
    row.range.selector = function(left) left[right, , drop = FALSE]
    range.selector = function(left) left[right]
    row.selector = function(left) left[right, , drop = TRUE]
    selector =
      function(left) {
        if(isS4(left))
          slot(left, right)
        else
          left[[right]]}
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




#iteration

`%@>%`=
  map =
  function(left, right) {
    lapply(left, asFunction(right))}

