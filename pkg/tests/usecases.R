library(dplyr)
library(yapo)

mtcars %>% ~filter(.., carb > 3)
mtcars %>% ~filter(carb > 3)
#filter records with carb greater than 3
letters %>% Range(sample(1:length(letters))) %>% ~tail(.., 3)
#scramble alphabet then take last three
letters %>% sample(1:length(letters), 1)
#random letter
mtcars %>% Range(c("carb", "cyl"))
# select two cols
mtcars %>% "carb" %>% mean
# take carb col and mean
mtcars %>% ~carb
# formula syntax
mtcars %>% Range(~carb)
# or selection of df like select(carb)
mtcars %>% ~carb %>% mean
# and then take mean
mtcars %>% ~carb %>% ~mean(x = ..)
#same with .. syntax, for functions with unusual arg order

mtcars %>% 1
#first col
mtcars %>% Row(1)
#first row as list
mtcars %>% Row(Range(1:10))
# first ten rows
mtcars %>% Range(Row(10))
#row 10 as data frame
mtcars %>% Range(Col(10:11))
# two cols
mtcars %>% Col(Range(10))
# one col as data fram
mtcars %>% Col(10)
#same as vector

ll =
  list(
    josh =
      list(
        age = 22,
        gender = "male",
        employed = TRUE),
    jeff =
      list(
        age = 32,
        gender = "male",
        employed = FALSE),
    jack =
      list(
        age = 42,
        gender = "male",
        employed = TRUE))
ll %>% "josh" %>% "age"
ll %>% ~josh %>% ~age
# nested list

4  %>% ~sqrt(sqrt(..))
#more predictable than magrittr

# iteration
#
#
letters  %@>% digest  %>% toupper %>% sort

