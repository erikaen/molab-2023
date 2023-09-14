//: [Previous](@previous)
/*:
 # Checkpoint 2
 This page is a practice from the previous coding.\
 Create an array of strings, then write some code that prints the number of items in the array and also the number of unique items in the array.
 */
//create an array of strings
let erikaFavDrinks = ["Coke", "Coke", "Sprite", "Fanta", "OJ"]
var numberDrinks = erikaFavDrinks.count
print("Number of drinks in the array: \(numberDrinks)")

//convert the array to a set to get unique items
var uniqueDrinks = Set(erikaFavDrinks)
var uniqueItemCount = uniqueDrinks.count
print("Number of unique drinks in the array: \(uniqueItemCount)")

//: [Next](@next)
