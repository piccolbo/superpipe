mtcars %[% ~filter(.., carb > 3)
mtcars %[[% ~filter(.., carb > 3)
#filter records with carb greater than 3
letters %[% sample(1:length(letters)) %[% ~tail(.., 3)
letters %[[% sample(1:length(letters), 1)
#scramble alphabet then take last three
mtcars %[% "carb"
mtcars %[[% "carb" %[[% mean
# take carb col and then take mean
mtcars %[% ~carb
mtcars %[[% ~carb %[[% mean
# same with formula syntax
mtcars %[[% ~carb %[[% ~mean(x = ..)
#same with .. syntax, for functions with unusual arg order