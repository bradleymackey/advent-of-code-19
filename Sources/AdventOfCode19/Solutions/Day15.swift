//
//  Day15.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

/// --- Day 15: Oxygen System ---
final class Day15: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    private lazy var data: [Int] = {
        input
            .split(separator: ",")
            .map(String.init)
            .compactMap(Int.init)
    }()
    
    func solvePartOne() -> CustomStringConvertible {
        let droid = RepairDroid(program: data)
        guard let oxygenLocation = droid.oxygenLocation else {
            return "ERROR, unable to find oxygen"
        }
        return droid.minimumSteps(to: oxygenLocation)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        "?"
    }
    
}

extension Day15 {
    
    final class RepairDroid {
        /*
        The remote control program executes the following steps in a loop forever:
        
         - Accept a movement command via an input instruction.
         - Send the movement command to the repair droid.
         - Wait for the repair droid to finish the movement operation.
         - Report on the status of the repair droid via an output instruction.
         */
        
        enum Direction: Int, CaseIterable, Hashable {
            case north = 1, south, west, east
            
            var vector: Coordinate {
                switch self {
                case .north: return [0, 1]
                case .south: return [0, -1]
                case .east:  return [1, 0]
                case .west:  return [-1, 0]
                }
            }
            
            var reverse: Direction {
                switch self {
                case .north: return .south
                case .south: return .north
                case .east:  return .west
                case .west:  return .east
                }
            }
            
            func moving(_ coordinate: Coordinate) -> Coordinate {
                coordinate &+ vector
            }
            
        }
        
        enum Item: Int {
            case wall = 0
            case empty
            case oxygen
            
            var symbol: String {
                switch self {
                case .wall:
                    return "#"
                case .empty:
                    return " "
                case .oxygen:
                    return "O"
                }
            }
            
            var canMoveInto: Bool {
                switch self {
                case .wall:
                    return false
                case .empty, .oxygen:
                    return true
                }
            }
        }
        
        let initialProgram: [Int: Int]
        private(set) var explored = [Coordinate: Item]()
        private(set) var oxygenLocation: Coordinate?
        
        /// create a repair droid and build the map
        init(program: [Int]) {
            self.initialProgram = Intcode.sparseInput(from: program)
            self.buildMap()
        }
        
        private func buildMap() {
            let computer = Intcode(data: initialProgram, inputs: [])
            explored[.zero] = .empty
            _dfsExplore(from: .zero, computer: computer)
            print(exploredAscii())
        }
        
        func exploredAscii() -> String {
            let minXCoordinate = explored.keys.min(by: { $0.x < $1.x })!.x
            let maxXCoordinate = explored.keys.max(by: { $0.x < $1.x })!.x
            let minYCoordinate = explored.keys.min(by: { $0.y < $1.y })!.y
            let maxYCoordinate = explored.keys.max(by: { $0.y < $1.y })!.y
            var map = Array(
                repeating: Array(repeating: "0", count: abs(minXCoordinate) + maxXCoordinate + 1),
                count: abs(minYCoordinate) + maxYCoordinate + 1
            )
            for location in explored {
                map[location.key.y + abs(minYCoordinate)][location.key.x + abs(minXCoordinate)] =
                    location.value.symbol
            }
            map[abs(minYCoordinate)][abs(minXCoordinate)] = "X"
            return map.map {
                $0.joined()
            }.joined(separator: "\n")
        }
        
        private func _dfsExplore(
            from coordinate: Coordinate,
            computer: Intcode
        ) {
            
            /// move the droid in a direction (if possible), report what it finds
            func move(into direction: Direction, using local: Intcode) -> Item {
                local.inputs = [direction.rawValue]
                let output = local.nextOutput()!
                return Item(rawValue: output)!
            }
            
            /// check what is in a direction without moving there
            func probe(_ direction: Direction, using local: Intcode) -> (Item, item: Coordinate) {
                let foundItem = move(into: direction, using: local)
                let itemLocation = direction.moving(coordinate)
                if foundItem.canMoveInto {
                    // moving into a free space modifies the state of the program, so revert this
                    _ = move(into: direction.reverse, using: local)
                }
                return (foundItem, itemLocation)
            }
            
            struct CandidatePosition: Hashable {
                let location: Coordinate
                let direction: Direction
            }
            
            var exploreNext = Set<CandidatePosition>()
            
            for direction in Direction.allCases {
                let (found, itemLocation) = probe(direction, using: computer)
                guard explored[itemLocation] == nil else { continue }
//                print(direction, "found new", found, "at", itemLocation)
                if found == .oxygen {
                    oxygenLocation = itemLocation
                }
                explored[itemLocation] = found
                if found.canMoveInto {
                    let candidate = CandidatePosition(location: itemLocation,
                                                      direction: direction)
                    exploreNext.insert(candidate)
                }
            }
            
            // @note: we copy the computer at each branch in the dfs so that each branch doesn't need to
            // backtrack all the way once exploration is done (because it's not easy to reset the droid
            // position otherwise)
            // @optimisation: so that we don't copy the whole computer memory for each explored cell, we only
            // create a copy if there is more than one possible branch, otherwise we can pass a reference to
            // the same computer down into the next recursive call
            var isComputerDirtied = false
            if exploreNext.count > 1 {
                isComputerDirtied = true
            }
            
            for place in exploreNext {
                let cleanComputer = isComputerDirtied ? computer.copy() : computer
                _ = move(into: place.direction, using: cleanComputer)
                _dfsExplore(from: place.location, computer: cleanComputer)
            }
            
        }
        
        func minimumSteps(to coordinate: Coordinate) -> Int {
            return 0
        }
    
    }
    
}