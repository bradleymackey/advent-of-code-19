//
//  Day12.swift
//  AdventOfCode
//
//  Copyright © 2019 Bradley Mackey. MIT Licenced.
//

import Foundation

/// --- Day 12: The N-Body Problem ---
/// - note: run in Release or this code can be quite slow, due to custom operators on Vector3
final class Day12: Day {
    
    let input: String
    
    init(input: String) {
        self.input = input
    }
    
    static func parseMoons(from input: String) -> [Moon] {
        input
            .split(separator: "\n")
            .map(String.init)
            .compactMap(Vector3.init)
            .enumerated()
            .reduce(into: [Moon]()) { set, payload in
                let (id, pos) = payload
                let moon = Moon(id: id, position: pos)
                set.append(moon)
            }
    }
    
    lazy var moons: [Moon] = Self.parseMoons(from: input)
    
    func runTests() -> CustomStringConvertible {
        return "-"
    }
    
    struct Iteration {
        let count: Int
        let positions: [Moon]
    }
    
    /// simulate the motion of the moons
    /// - Parameter iterationHandler: how to handle each iteration. return `true` to stop simulation, `false`
    /// to continue simulating
    func simulateMoonMotion(iterationHandler: (Iteration) -> Bool) {
        // first update the velocity of every moon by applying gravity.
        // then update the position of every moon by applying velocity.
        // Time progresses by one step once all of the positions are updated.
        var activeMoons = moons
        let numMoons = moons.count
        var itr = 0
        while true {
            do {
                defer { itr += 1 }
                // -- apply gravity --
                let currentMoons = activeMoons
                var updatedMoons = activeMoons
                for idx in 0..<numMoons {
                    updatedMoons[idx].applyGravityField(from: currentMoons)
                }
                // -- update velocity --
                for idx in 0..<numMoons {
                    updatedMoons[idx].applyCurrentVelocity()
                }
                // -- update moons --
                activeMoons = updatedMoons
            }
            
            let iteration = Iteration(count: itr, positions: activeMoons)
            // return true to stop the loop
            if iterationHandler(iteration) { break }
        }
    }
    
    func solvePartOne() -> CustomStringConvertible {
        var finalPositions = [Moon]()
        simulateMoonMotion { itr -> Bool in
            guard itr.count == 1000 else { return false }
            finalPositions = itr.positions
            return true
        }
        return finalPositions.map(\.totalEnergy).reduce(0, +)
    }
    
    func solvePartTwo() -> CustomStringConvertible {
        print("🌕 Calculating part 2 iterations (very slow in Debug)")

        let initialMoons = moons
        var found = SIMD3(x: -1, y: -1, z: -1)
        
        
        simulateMoonMotion { (itr) -> Bool in
            if found.min() != -1 { return true }
            let (eqx, eqy, eqz) = itr.positions.equalState(to: initialMoons)
            let currentItr = itr.count
            if found.x == -1, eqx {
                found.x = currentItr
                print("found x at itr", currentItr)
            }
            if found.y == -1, eqy {
                found.y = currentItr
                print("found y at itr", currentItr)
            }
            if found.z == -1, eqz {
                found.z = currentItr
                print("found z at itr", currentItr)
            }
            return false
        }

        return lcm(found.x, found.y, found.z)
    }
    
}


extension Day12 {
    
    struct Moon: Hashable, Equatable, CustomStringConvertible {
        let id: Int
        var position: Vector3
        var velocity: Vector3 = .zero
        
        var description: String {
            """
            [id:\(id), pos:\(position), vel:\(velocity)]
            """
        }
        
        init(id: Int, position: Vector3) {
            self.id = id
            self.position = position
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Moon, rhs: Moon) -> Bool {
            lhs.id == rhs.id
        }
        
        mutating func applyCurrentVelocity() {
            position += velocity
        }
        
        mutating func applyGravityField(from moonField: [Moon]) {
            for moon in moonField where moon.id != self.id {
                applyGravity(from: moon)
            }
        }
        
        mutating func applyGravity(from other: Moon) {
            velocity += velocityDelta(applyingGravityFrom: other)
        }
        
        func velocityDelta(applyingGravityFrom other: Moon) -> Vector3 {
            let newX = gravityAdjustAmount(us: position.x, them: other.position.x)
            let newY = gravityAdjustAmount(us: position.y, them: other.position.y)
            let newZ = gravityAdjustAmount(us: position.z, them: other.position.z)
            return Vector3(x: newX, y: newY, z: newZ)
        }
        
        private func gravityAdjustAmount(us: Int, them: Int) -> Int {
            if us < them {
                return +1
            } else if us > them {
                return -1
            } else {
                return 0
            }
        }
        
        var potentialEnergy: Int {
            position.distanceToOrigin
        }
        
        var kineticEnergy: Int {
            velocity.distanceToOrigin
        }
        
        var totalEnergy: Int {
            potentialEnergy * kineticEnergy
        }
        
    }
    
}

extension Array where Element == Day12.Moon {
    
    func equalState(to other: [Day12.Moon]) -> (x: Bool, y: Bool, z: Bool) {
        guard self.count == other.count else { return (false, false, false) }
        var result: SIMD3<UInt8> = [1, 1, 1]
        for idx in 0..<count {
            guard result != [0, 0, 0] else { return (false, false, false) }
            let ourMoon = self[idx]
            let theirMoon = other[idx]
            let position = ourMoon.position .== theirMoon.position
            result = result & position
            let velocity = ourMoon.velocity .== theirMoon.velocity
            result = result & velocity
        }
        return (result.x > 0, result.y > 0, result.z > 0)
    }
    
}

extension Vector3 {
    
    /// of the form <x=4, y=1, z=1>
    public init?(string: String) {
        // pull out only the numbers, convert to Int
        let nums = string
            .components(separatedBy: CharacterSet.decimalDigits.union(.init(charactersIn: "-")).inverted)
            .compactMap(Int.init)
        guard nums.count == 3 else { return nil }
        self.init(x: nums[0], y: nums[1], z: nums[2])
    }
    
}


extension Day12 {
    
    static var testInput1: String {
        """
        <x=-1, y=0, z=2>
        <x=2, y=-10, z=-7>
        <x=4, y=-8, z=8>
        <x=3, y=5, z=-1>
        """
    }
    
}
