import algorithm
import sequtils
import strutils

type
    Crate = string
    Stack = seq[Crate]
    Crates = seq[Stack]
    Rearrangement = tuple
        `from`: int
        to: int
        amount: int
    Problem = tuple
        crates: Crates
        rearrangements: seq[Rearrangement]

proc readInputFile(): string =
    return readFile("input.txt")

proc parseCrates(crates: string): Crates =
    let lines = crates.splitLines()
    var crates: Crates = @[]
    let totalCrates = lines[^1].strip().split("   ").len()
    for _ in 0 ..< totalCrates:
        crates.add(@[])

    for line in reversed(lines[0 ..< ^1]):
        for i in 0 ..< totalCrates:
            let crate = $line[4*i+1]
            if crate != " ":
                crates[i].add(crate)
    return crates

proc parseRearrangement(rearrangement: string): Rearrangement =
    let parts = rearrangement.split(" ")
    return (
        `from`: parseInt(parts[3]),
        to: parseInt(parts[5]),
        amount: parseInt(parts[1]),
    )

proc parseRearrangements(rearrangements: string): seq[Rearrangement] =
    return rearrangements.splitLines().map(parseRearrangement)

proc parseProblem(input: string): Problem =
    let parts = input.split("\n\n")
    return (
        crates: parseCrates(parts[0]),
        rearrangements: parseRearrangements(parts[1]),
    )

proc rearrange(crates: var Crates, rearrangement: Rearrangement) =
    for _ in 1..rearrangement.amount:
        let crate = crates[rearrangement.`from`-1].pop()
        crates[rearrangement.to-1].add(crate)

proc rearrange2(crates: var Crates, rearrangement: Rearrangement) =
    var buffer: seq[Crate] = @[]
    for _ in 1..rearrangement.amount:
        buffer.add(crates[rearrangement.`from`-1].pop())

    for crate in reversed(buffer):
        crates[rearrangement.to-1].add(crate)

proc part1(problem: Problem): string =
    var crates = problem.crates
    for rearrangement in problem.rearrangements:
        rearrange(crates, rearrangement)
    return crates.map(proc(stack: Stack): Crate = stack[^1]).join()

proc part2(problem: Problem): string =
    var crates = problem.crates
    for rearrangement in problem.rearrangements:
        rearrange2(crates, rearrangement)
    return crates.map(proc(stack: Stack): Crate = stack[^1]).join()

proc main() =
    let problem = parseProblem(readInputFile())
    echo "Part 1: ", part1(problem)
    echo "Part 2: ", part2(problem)

main()
