//: [Previous](@previous)
/*:
 # Day 3
 Arrays, dictionaries, sets, and enums.
 */

//arrays
var beatles = ["John", "Paul", "George", "Ringo"]
let numbers = [4, 8, 15, 16, 23, 42]
var temperatures = [25.3, 28.2, 26.4]
print(beatles[0])
print(numbers[1])
print(temperatures[2])

beatles.append("Adrian")
beatles.append("Allen")
beatles.append("Adrian")
beatles.append("Novall")
beatles.append("Vivian")
//temperatures.append("Chris") is not allowed, cannot put strings into decimal numbers
let firstBeatle = beatles[0]
let firstNumber = numbers[0]
//let notAllowed = firstBeatle + firstNumber

var scores = Array<Int>() //this is an array only hold integers
scores.append(100)
scores.append(80)
scores.append(85)
print(scores[1])

var albums = Array<String>()
albums.append("Folklore")
albums.append("Fearless")
albums.append("Red")
/*
var albums = [String]() //same as the previous array
albums.append("Folklore")
albums.append("Fearless")
albums.append("Red")
var albums = ["Folklore"] //swift will understand this
albums.append("Fearless")
albums.append("Red")
*/
print(albums.count)

var characters = ["Lana", "Pam", "Ray", "Sterling"]
print(characters.count)

characters.remove(at: 2) //remove "Ray"
print(characters.count)

characters.removeAll()
print(characters.count)

let bondMovies = ["Casino Royale", "Spectre", "No Time To Die"]
print(bondMovies.contains("Frozen")) //use this to check

let cities = ["London", "Tokyo", "Rome", "Budapest"]
print(cities.sorted()) //Alphabetical order

let presidents = ["Bush", "Obama", "Trump", "Biden"]
let reversedPresidents = presidents.reversed()
print(reversedPresidents) //swift tells you it is reversed but not gonna show it hehe


//dictionaries
var employee = ["Taylor Swift", "Singer", "Nashville"]
print("Name: \(employee[0])")
print("Job title: \(employee[1])")
print("Location: \(employee[2])")
print("Name: \(employee[0])")
employee.remove(at: 1)
//print("Job title: \(employee[1])")
//print("Location: \(employee[2])")

//let employee2 = ["name": "Taylor Swift", "job": "Singer", "location": "Nashville"]
let employee2 = [
    "name": "Taylor Swift",
    "job": "Singer",
    "location": "Nashville"
]
/*
print(employee2["name"])
print(employee2["job"])
print(employee2["location"])
print(employee2["password"])
print(employee2["status"])
print(employee2["manager"])
*/
print(employee2["name", default: "Unknown"])
print(employee2["job", default: "Unknown"])
print(employee2["location", default: "Unknown"])


let hasGraduated = [
    "Eric": false,
    "Maeve": true,
    "Otis": false,
]

let olympics = [
    2012: "London",
    2016: "Rio de Janeiro",
    2021: "Tokyo"
]

print(olympics[2012, default: "Unknown"])

var heights = [String: Int]() //strings as keys and integers as values
heights["Yao Ming"] = 229
heights["Shaquille O'Neal"] = 216
heights["LeBron James"] = 206

var archEnemies = [String: String]()
archEnemies["Batman"] = "The Joker"
archEnemies["Superman"] = "Lex Luthor"
archEnemies["Batman"] = "Penguin" //overwrite

//sets
let people = Set(["Denzel Washington", "Tom Cruise", "Nicolas Cage", "Samuel L Jackson"])
print(people)
//there is no order in sets

var people1 = Set<String>()
people1.insert("Denzel Washington")
people1.insert("Tom Cruise")
people1.insert("Nicolas Cage")
people1.insert("Samuel L Jackson")
print(people1)

//enums
var selected = "Monday"
selected = "Tuesday"
selected = "January"
selected = "Friday " //an extra space

enum Weekday {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
}

/*
 var day = Weekday.monday
day = Weekday.tuesday
day = Weekday.friday
*/

enum Weekday1 {
    case monday, tuesday, wednesday, thursday, friday
} //this is an easier way to write

var day = Weekday.monday
day = .tuesday
day = .friday

//: [Next](@next)
