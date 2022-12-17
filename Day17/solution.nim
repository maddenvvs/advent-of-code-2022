import algorithm
import sets
import sequtils
import strutils
import sugar

type
    Jet = enum
        Left, Right
    Coordinate = (int, int)
    Shape = object
        width: int
        height: int
        blocks: HashSet[Coordinate]

let available_shapes = [
    Shape(
        width: 4,
        height: 1,
        blocks: toSeq(0..3).map(x => (x, 0)).toHashSet()
    ),
    Shape(
        width: 3,
        height: 3,
        blocks: [
            (0, 1),
            (1, 0),
            (1, 1),
            (1, 2),
            (2, 1),
        ].toHashSet()
    ),
    Shape(
        width: 3,
        height: 3,
        blocks: [
            (0, 0),
            (1, 0),
            (2, 0),
            (2, 1),
            (2, 2),
        ].toHashSet()
    ),
    Shape(
        width: 1,
        height: 4,
        blocks: toSeq(0..3).map(y => (0, y)).toHashSet()
    ),
    Shape(
        width: 2,
        height: 2,
        blocks: [
            (0, 0),
            (1, 0),
            (0, 1),
            (1, 1),
        ].toHashSet()
    ),
]

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseProblem(input: string): seq[Jet] =
    return input.map(ch => (if ch == '>': Jet.Right else: Jet.Left))

proc displayChamber(rocks: HashSet[Coordinate]) =
    var maxY: int
    for (_, y) in rocks:
        maxY = max(maxY, y)

    var display = toSeq(0..maxY).map(_ => toSeq(1..7).map(_ => '.'))
    for (x, y) in rocks:
        display[y][x] = '#'

    for row in reversed(display):
        echo row.join()

iterator simulate(jetPattern: seq[Jet]): (int, int) =
    var
        rocks: HashSet[Coordinate]
        maxHeight: int
        currentShapeIdx: int
        currentJetIdx: int
        shapeNumber: int

    while true:
        let currentShape = available_shapes[currentShapeIdx]

        var (cx, cy) = (2, maxHeight+3)
        var currentBlocks = currentShape.blocks.map(b => (b[0]+cx, b[1]+cy))

        while true:
            let currentJet = jetPattern[currentJetIdx]
            currentJetIdx = (currentJetIdx + 1) mod jetPattern.len()
            let dx = (if currentJet == Jet.Left: -1 else: 1)
            let nx = cx + dx
            if nx >= 0 and nx + currentShape.width <= 7:
                let shiftedBlocks = currentBlocks.map(b => (b[0] + dx, b[1]))
                if shiftedBlocks.intersection(rocks).len() == 0:
                    currentBlocks = shiftedBlocks
                    cx = nx

            let ny = cy - 1
            if ny < 0:
                for rock in currentBlocks:
                    rocks.incl(rock)
                break

            let fallingBlocks = currentBlocks.map(b => (b[0], b[1] - 1))
            if fallingBlocks.intersection(rocks).len() > 0:
                for rock in currentBlocks:
                    rocks.incl(rock)
                break

            currentBlocks = fallingBlocks
            cy = ny

        currentShapeIdx = (currentShapeIdx + 1) mod available_shapes.len()
        maxHeight = max(maxHeight, cy + currentShape.height)
        shapeNumber += 1

        yield (shapeNumber, maxHeight)

proc findPeriodAndOffset(jetPattern: seq[Jet]): (uint64, uint64) =
    return (1740u64, 175u64)

proc findHeightAfterSimulating(jetPattern: seq[Jet], shapes: uint64): uint64 =
    var shapes = shapes
    var heights: seq[int]
    let (period, offset) = findPeriodAndOffset(jetPattern)

    for idx, maxHeight in simulate(jetPattern):
        if uint64(idx) > offset + period:
            break
        heights.add(maxHeight)

    var totalHeight: uint64 = uint64(heights[offset - 1])
    shapes -= offset

    let periodDiff: uint64 = uint64(heights[period+offset-1] - heights[offset-1])
    let fullPeriods = shapes div period
    let remainder = shapes mod period

    totalHeight += fullPeriods * periodDiff
    totalHeight += uint64(heights[remainder+offset-1] - heights[offset-1])

    return totalHeight

proc part1(jetPattern: seq[Jet]): uint64 =
    return findHeightAfterSimulating(jetPattern, 2022)

proc part2(jetPattern: seq[Jet]): uint64 =
    return findHeightAfterSimulating(jetPattern, 1000000000000u64)

proc main() =
    var jetPattern = parseProblem(readInputFile())
    echo "Part 1: ", part1(jetPattern)
    echo "Part 2: ", part2(jetPattern)

main()
