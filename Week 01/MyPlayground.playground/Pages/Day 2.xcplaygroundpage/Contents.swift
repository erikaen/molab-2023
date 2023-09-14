//: [Previous](@previous)
/*:
 # Day 2
 Booleans and string interpolation.
 */

//booleans
let filename = "paris.jpg"
print(filename.hasSuffix(".jpg"))

let number = 120
print(number.isMultiple(of: 3))

let goodDogs = true
let gameOver = false
let isMultiple = 120.isMultiple(of: 3)

var isAuthenticated = false
isAuthenticated = !isAuthenticated
print(isAuthenticated)
isAuthenticated = !isAuthenticated
print(isAuthenticated)

var gameOver1 = false
print(gameOver1)

gameOver1.toggle() //same as using ! marks
print(gameOver1)

//join strings
let firstPart = "Hello, "
let secondPart = "world!"
let greeting = firstPart + secondPart

let people = "Haters"
let action = "hate"
let lyric = people + " gonna " + action
print(lyric)

let luggageCode = "1" + "2" + "3" + "4" + "5"

let quote = "Then he tapped a sign saying \"Believe\" and walked away."

let name = "Taylor"
let age = 26
let message = "Hello, my name is \(name) and I'm \(age) years old."
print(message)

let number1 = 11
//this is not allowed: let missionMessage = "Apollo " + number1 + " landed on the moon."
let missionMessage = "Apollo " + String(number1) + " landed on the moon."
//let missionMessage = "Apollo \(number1) landed on the moon."

print("5 x 5 is \(5 * 5)")
//: [Next](@next)
