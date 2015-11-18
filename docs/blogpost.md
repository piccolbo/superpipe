# An R pipe operator for interactive and programming use










## Prologue

The *pipe operator*, `%>%` in its latest incarnation, is all the rage in R circles. I first saw it in a less-well-known package called [`vadr`](https://github.com/crowding/vadr). Then one was added to [`dplyr`](https://github.com/hadley/dplyr), but I preferred my own implementation when working on [`plyrmr`](https://github.com/RevolutionAnalytics/plyrmr). Then a dedicated package emerged called [`magrittr`](http://github.com/smbache/magrittr) and it became the de-facto standard among pipe lovers when `dplyr` switched to it. The pipe operator allows to write 

```
f(g(g.arg1, g.arg2, ...), f.arg2, ...)
```

as 

```
g(g.arg1, g.arg2, ...) %>% f(f.arg2, ...)
```

for any functions `f` and `g`. The advantages of this style have been discussed [in depth](http://www.r-statistics.com/2014/08/simpler-r-coding-with-pipes-the-present-and-future-of-the-magrittr-package/) and are not the subject of this post.


## Critique of Non Standard Evaluation
It should be clear to anyone with a moderate knowledge of R that evaluating `f(f.arg2, ...)` while taking its first argument from somewhere else requires some form of non standard evaluation (NSE). Standard evaluation would complain about a missing argument or use a default if available. NSE has a long tradition in R going back to `base` functions such as `transform` and `subset`. In the case of those functions, columns of the first argument, always a data frame, can be mentioned by name in other arguments as if they were additional in-scope variables, 


```r
transform(mtcars, carb/cyl)
```
which is arguably better than 

```r
transform(mtcars, "carb/cyl")
```
or 

```r
transform(mtcars, mtcars$carb/mtcars$cyl)
```

The much more recent `dplyr` has picked up this idiom, improved it and applied it consistently to an organized set of primitives to manipulate data frames. Unfortunately, when one starts programming with these functions, some drawbacks emerge. The first and most obvious one, is that parametrizing arguments is difficult. Imagine we are writing a function that does something on a column, any column of a data frame: `function(df, col)`. In the body of that function, we need to use `transform` to create a new column that depends on the column identified by `col`. You may think right off the bat something like `transform(df, newcol = col^2)`, but that would just look for a column named `"col"`, not anything to deal with the value of the variable `col`. There are even more subtle problems when using `transform` in functions nested inside other functions. The documentation for `transform` is pretty clear about this: "For programming it is better to use the standard subsetting arithmetic functions, and in particular the non-standard evaluation of argument `transform` [sic, there is no such argument] can have unanticipated consequences". It seems to me that one of the great strengths of R is that it works both as a UI for people doing statistics as well as a programming language, and creating separate jargons for the two use cases may offer some short term benefits, but in the long run weakens the dual nature of R and makes the transition to programming harder. It's coding candy: attractive, but not good for your teeth. `dplyr` offers some relief from this by providing NSE-free versions of the most important functions and a more general NSE implementation. Still, the duality is there and the section of the API using NSE needs to be replicated. That's big price to pay. Adding that, perplexingly, the names of NSE and NSE-free functions differ only by a cryptic and pretty much invisible `_`, my opinion is that we can do better than that. 

``magrittr::`%>%` `` is not immune to the same type of criticism. For instance, one can write 


```r
library(magrittr)
mtcars %>% filter(mpg>15)
```

```
    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
6  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
7  24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
....
```

but not


```r
myfilter = filter(mpg>15)
```

```
Error in filter_(.data, .dots = lazyeval::lazy_dots(...)): object 'mpg' not found
```

```r
# aiming for:
# mtcars %>% myfilter
```

which means `magrittr` promotes the use of expressions that are not first class in R, because they are not assignable to a variable, cannot be passed to a function and so forth, which hampers programmability. Moreover, if we enter:


```r
4 %>% sqrt(.)
```

```
[1] 2
```
where `.` is a special variable evaluating to the left side argument of the `%>%` operator. Surprisingly, though, 


```r
4  %>% sqrt(sqrt(.))
```

```
Error in sqrt(., sqrt(.)): 2 arguments passed to 'sqrt' which requires 1
```

fails, showing a lack of *composability*, an important goal in API design. 

## Critique of `purrr` reason

Given these considerations, I wasn't too surprised when I found that a new package by `dplyr`'s author, `purrr`, tries a different approach that avoids NSE. `purrr` is a package for processing lists inspired by javascript's `underscore.js`. A typical function is `map`, which applies a function to every element of its first argument, for example `map(mtcars, class)`. Besides taking a function, `map` accepts also a `character` or a `numeric`, which it transforms into an accessor function. Moreover, one can pass formulas that provide a quick notation for defining functions and pretty much replace NSE. It only takes a little `~` in front of an expression to explicitly suspend the normal evaluation mechanism and trigger a context-dependent one. It's a kind of on demand NSE and it expands the use of formulas outside model fitting. Formulas are perfectly set up for this, as they carry with them their intended evaluation environment, making it relatively easy to provide correct implementations that work in any context as opposed to, say, only at top level.

## A New Pipe Operator

This gave me an idea: define a NSE-free pipe operator that processes its second argument like `purrr::map` does with its own. Thus was conceived a new package, `yapo`, for "Yet Another Pipe Operator", a name chosen in homage to `yacc` and to acknowledge the proliferation of pipe operators. Taking `dplyr` and replacing NSE with the same approach would be equally interesting, but it will have to wait.

So how does this pipe operator look like? First of all, very much compatible with the one in `magrittr`, which is the same as the one in `dplyr`. 

```
mtcars %>% filter(mpg > 15)
``` 
becomes 


```r
suppressMessages(library(yapo))
mtcars %>% ~filter(mpg > 15)
```

```
    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
6  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
7  24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
....
```

The difference is just one additional `~`. This is a small price to pay for seamless parametrizability. Imagine you need to use that filter several times in a program, or pass it as an argument. You can just use a variable:


```r
myfilter = ~filter(mpg > 15)
mtcars %>% myfilter
```

```
    mpg cyl  disp  hp drat    wt  qsec vs am gear carb
1  21.0   6 160.0 110 3.90 2.620 16.46  0  1    4    4
2  21.0   6 160.0 110 3.90 2.875 17.02  0  1    4    4
3  22.8   4 108.0  93 3.85 2.320 18.61  1  1    4    1
4  21.4   6 258.0 110 3.08 3.215 19.44  1  0    3    1
5  18.7   8 360.0 175 3.15 3.440 17.02  0  0    3    2
6  18.1   6 225.0 105 2.76 3.460 20.22  1  0    3    1
7  24.4   4 146.7  62 3.69 3.190 20.00  1  0    4    2
....
```

It just works as expected. Please try that with `magrittr` and let me know. The best I could come up with was 

```
myfilter = function(x) filter(x, mpg > 15)
``` 

which is OK, but different, and that's the whole point: getting almost the same conciseness as with NSE while developing a jargon, or DSL, that can work for interactive R as well programming in R.
Another difference with `magrittr` is that `yapo` is meant to be simple in definition and implementation. Hence 



```r
4 %>% ~sqrt(sqrt(..))
```

```
[1] 1.414214
```

just works, no excuses. Please  notice the use of `..` instead of `.` to avoid confusion with `.` as used in models. 

These are use cases suggested by `dplyr`, but there are others that come from `purrr` and are here unified in a single operator. What `purrr` can do on a list of elements, `%>% ` does on a single element. For instance, 
`purrr::map(a.list, a.string)` accesses all the elements named after the value of `a.string` in the elements of list `a.list`, equivalent to 

```
purrr::map(a.list, function(x) x[[a.string]])
```

It may be a small difference, but type the long version many enough times and you are going to be grateful for the shorthand. In analogy with `purrr`, we can use integer and character vectors on the right side of `%>%`, implicitly creating an accessor function that gets then applied to the left side, as in  


```r
mtcars %>% "carb"
```

```
 [1] 4 4 1 1 2 1 4 2 2 4 4 3 3 3 4 4 4 1 2 1 1 2 2 4 2 1 2 2 4 6 8 2
```
which is the same as `mtcars[["carb"]]`. You may be protesting that that's a very small difference, but bear with me a little longer. `%>%` unifies vector, list, data frame, matrix, S3 and S4 object access. Yes, no more getting errors when using `[[]]` on S4 objects, enough of that. It works also on 2D data structures such as data frames and matrices, with the help of a couple of functions (credit @ctbrown for this idea). The default is column access. If, instead, row access is desired, one only needs to use the function `Row` as in 


```r
mtcars %>% Row(3)
```

```
$mpg
[1] 22.8

$cyl
[1] 4

$disp
[1] 108
....
```

One can also access multiple columns with the `Range` function as in 


```r
mtcars %>% Range(c("carb", "cyl"))
```

```
                    carb cyl
Mazda RX4              4   6
Mazda RX4 Wag          4   6
Datsun 710             1   4
Hornet 4 Drive         1   6
Hornet Sportabout      2   8
Valiant                1   6
Duster 360             4   8
....
```

`Range` and `Row` can be composed to select a range of rows:


```r
mtcars %>% Row(Range(1:4))
```

```
                mpg cyl disp  hp drat    wt  qsec vs am gear carb
Mazda RX4      21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
Mazda RX4 Wag  21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
Datsun 710     22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
```

When selecting ranges, the result type is always the same as the input type, unlike with `[,]` and its ill-advised `drop` option. Of course, selecting ranges in S3 or S4 objects will fail in most cases because it doesn't make sense. The formula notation keeps working and you can use it to cut down on the typing quite a bit. The evaluation environment of the formula is expanded, as we have seen, with a variable `..` but also with a variable for each named element of  the left argument of the pipe, in analogy with `dplyr`. Imagine you have a list of teams of people, each with personal information including a phone, in  a three-level nested list (named at all levels). 


```r
teams = 
  list(
    Avengers = 
      list(
        Annie = 
          list(
            phone = "222-222-2222"),
        Paula = 
          list(
            phone = "333-333-3333")),
    EmptyTeam = list())
```
  
You can access Annie's phone in team "Avengers" with 


```r
teams %>% ~Avengers %>% ~Annie %>% ~phone
```

```
[1] "222-222-2222"
```

which, using with the Rstudio shortcut for `%>%`, is pretty convenient to type, as opposed to 


```r
teams[["Avengers"]][["Annie"]][["phone"]]
```

```
[1] "222-222-2222"
```

(6 vs. 18 additional keystrokes, excluding names). Whether it looks better, that's subjective.

## The making of `yapo`

While a fairly simple package, there were a couple of technical hurdles in implementing `yapo`. The first is that custom operators in R, the ones that start and end with a `%`, have higher priority than `~`. That would have forced us to protect every formula but the last one in a complex pipe  with `()`. To avoid that, `yapo` reverses the priority of `%>%` and `~`. It's a testament to the flexibility of the language that this is at all possible. The other hairy problem was guessing when the first argument of a function is missing, as in `filter(mpg > 15)`. We settled for testing for missing arguments with no defaults. For instance, the `.data` argument to `filter` has no default and is  not provided in `filter(mpg > 15)`. Hence it is necessary to add the special argument `..` and the convention is to add it as the first, unnamed argument, which works well with `dplyr` functions and many other reasonably designed APIs. It's a heuristic and if it doesn't work in some cases you just have to explicitly add `..`, as in `sqrt(sqrt(..))`.


## Thou shalt code

And with that, please install `yapo` and let me know how you like it. Install is as simple as `devtools::install_github("piccolbo/yapo/pkg")`. Remember to load after `magrittr` or `dplyr` to shadow their own pipe operators. 


