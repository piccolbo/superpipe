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

missing.args =
  function(acall, envir) {
    formargs =  formals(eval(acall[[1]], envir = envir))
    if(is.null(formargs))
       FALSE
    else{
      mandatory =
        names(formargs)[
        sapply(formargs, is.name) & (as.character(formargs) == "")]
      provided =
        as.character(
          match.call(eval(acall[[1]], envir = envir), acall)[-1])
      !all(mandatory %in% c(provided, "..."))}}

as.list.S4 =
  function(x, ...)
    setNames(
      lapply(slotNames(x), function(n) slot(d, n)),
      slotNames(x))

asFunction.formula =
  function(right) {
    rexpr = as.list(right)[[2]]
    renvir = environment(right)
    if("call" %in% class(rexpr) &&
       !(".." %in% all.vars(rexpr)) &&
       missing.args(rexpr, renvir))
      rexpr =
      as.call(
        c(
          list(
            rexpr[[1]],
            quote(..)),
          as.list(rexpr)[-1]))
    function(left) {
      eval(
        rexpr,
        c(
          list(.. = left),
          if(isS4(left))
            as.list.S4(left)
          else
            as.list(left)),
        renvir)}}

asFunction.default =
  function(right) {
    row.range.selector =
      function(left)
        as(left[right, , drop = FALSE], class(left))
    range.selector = function(left) as(left[right], class(left))
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

