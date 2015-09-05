mtcars %~>% ~filter(.., carb > 3)
de#filter records with carb greater than 3
letters %~>% range(sample(1:length(letters))) %~>% ~tail(.., 3)
#scramble alphabet then take last three
letters %~>% sample(1:length(letters), 1)
#random letter
mtcars %~>% range("carb", "cyl")
# select two cols
mtcars %~>% "carb" %~>% mean
# take carb col and then take mean
mtcars %~>% ~carb
mtcars %~>% ~carb %~>% mean
# same with formula syntax
mtcars %~>% ~carb %~>% ~mean(x = ..)
#same with .. syntax, for functions with unusual arg order