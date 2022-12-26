import sets
import sequtils
import strutils
import sugar
import tables

type
    Coordinate = (int, int)

let
    invalidPosition = (int.high(), int.high())
    neighbours = [
        (-1, -1),
        (-1, 0),
        (-1, 1),
        (0, -1),
        (0, 1),
        (1, -1),
        (1, 0),
        (1, 1),
    ]
    directions = [
        [(-1, 0), (-1, 1), (-1, -1)],
        [(1, 0), (1, 1), (1, -1)],
        [(0, -1), (-1, -1), (1, -1)],
        [(0, 1), (-1, 1), (1, 1)],
    ]

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseProblem(input: string): seq[seq[char]] =
    return input.splitLines().map(v => v.toSeq())

proc isNoOneAround(elf: Coordinate, elves: HashSet[Coordinate]): bool =
    let (cr, cc) = elf
    for (dr, dc) in neighbours:
        let n = (cr+dr, cc+dc)
        if n in elves:
            return false
    return true

proc findNextPosition(
    elf: Coordinate,
    elves: HashSet[Coordinate],
    round: int,
): Coordinate =
    let n = directions.len()
    let (cr, cc) = elf

    for idx in 0..3:
        var validDirection = true
        for (dr, dc) in directions[(round + idx) mod n]:
            let np = (cr+dr, cc+dc)
            if np in elves:
                validDirection = false
                break

        if validDirection:
            let (dr, dc) = directions[(round + idx) mod n][0]
            return (cr+dr, cc+dc)

    return invalidPosition

proc simulateRound(
    elves: HashSet[Coordinate],
    round: int,
): (HashSet[Coordinate], int) =
    var proposedPositions: Table[Coordinate, seq[Coordinate]]

    for elf in elves:
        if isNoOneAround(elf, elves):
            continue

        let nextPos = findNextPosition(elf, elves, round)
        if nextPos == invalidPosition:
            continue

        if not (nextPos in proposedPositions):
            proposedPositions[nextPos] = @[]

        proposedPositions[nextPos].add(elf)

    var movingElves: HashSet[Coordinate]
    var newElves: HashSet[Coordinate]
    for key, value in proposedPositions.pairs():
        if value.len() == 1:
            movingElves.incl(value[0])
            newElves.incl(key)

    for elf in elves:
        if not (elf in movingElves):
            newElves.incl(elf)

    return (newElves, movingElves.len())

proc findBoundRectangle(elves: HashSet[Coordinate]): (Coordinate, Coordinate) =
    var minR, minC = int.high()
    var maxR, maxC = int.low()

    for (r, c) in elves:
        minR = min(minR, r)
        minC = min(minC, c)
        maxR = max(maxR, r)
        maxC = max(maxC, c)

    return ((minR, minC), (maxR, maxC))

proc prepareElves(board: seq[seq[char]]): HashSet[Coordinate] =
    var elves: HashSet[Coordinate]
    for r, row in board:
        for c, v in row:
            if v == '#':
                elves.incl((r, c))
    return elves

proc part1(board: seq[seq[char]]): int =
    var elves = prepareElves(board)

    for round in 0..9:
        let res = simulateRound(elves, round)
        elves = res[0]

    let (tl, br) = findBoundRectangle(elves)
    let area = (br[0] - tl[0] + 1) * (br[1] - tl[1] + 1)
    return area - elves.len()

proc part2(board: seq[seq[char]]): int =
    var elves = prepareElves(board)

    var round = 0
    while true:
        let res = simulateRound(elves, round)
        if res[1] == 0:
            break
        elves = res[0]
        round += 1

    return round + 1

proc main() =
    var board = parseProblem(readInputFile())
    echo "Part 1: ", part1(board)
    echo "Part 2: ", part2(board)

main()
