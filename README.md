# Advent Of Code 2019

At attempt at Advent of Code 2019 using only Swift, written as "Swiftly" as possible.
Feel free to look around.

I've been fascinated with Swift's general-purpose languge features for a long time, and AOC is the perfect excuse to put that framework-independent, pure-language applicability to the test.

## Usage Tips

Run in `Release`, that is, `-O` optimisation level.
This can cause at least an _order of magnitude_ of speed improvements on some challenges (i.e. Day 12, Day 18).
All other challenges run many times faster as well.

> Insert comment about how `-Onone` is suprisingly slow.

## Thoughts, Feelings and Observations

### Questions

- Excellent ranging of levels of difficultly and novel questions make for an exciting time. Clearly very well thought out.
- Part 2 always built very well on Part 1. Code could generally be reused, but needed to be though of in a different way.
This often led to a refactoring and fundamental improvement of the original code for both parts of the question.

### Swift

Good:

- `enum`s are expressive, powerful and efficient. They can be used instead of `struct` in more places than you might think when modelling.
- The ability to easily choose between value semantics (`enum`, `struct`) and reference semantics (`class`) still is one of my favourite features of Swift. The fact that the system manages the additional levels of abstraction for you (for the most part, see Reference Cycles) means that in many cases `struct` and `class` keywords can just be swapped out instantly for a change in the semantics of the model type (no need for additional boxing, wrapping or heap memory management). This language feature shows it's worth time and time again, and I absolutely do not take it for granted!
- I'm absolutely an advocate of protocol oriented programming. In many cases it makes more sense than a class hierarchy, as model objects typically adopt multiple, _distinct_ behaviours.

Bad:

- Needs more general-purpose algorithms and data structures available by default (think `collections` module from Python).
- `-Onone` is _suprisingly_ slow in some cases, especially when using custom operators (no amount of `@inline(__always)` seems to help).
Run the project with and without optimisations enabled to see what I mean.
- `KeyPaths` property accesses are (in general) ~10x slower than direct property accesses. 
- Why is there no `Character` literal (`'A'`) yet?
- Pattern matching expressions directly are not supported, which is really annoying when trying to match on `enum`s with associated values:

> Expectation: `people.filter { case .man(age: 30) }`
>
> Reality: `people.filter { if case .man(age: 30) = $0 { return true } else { return false } }`

### Xcode

Bad:

- It doesn't work as well with Swift packages as it does with Xcode projects.
Losing the state of opened folders when opening the project, for example.
- I'd like an easier way to change program arguments and Swift compilation flags than having to dig into the scheme settings all the time.
