import sets
import sequtils
import strutils
import sugar

type
    Coordinate = (int, int)
    RockPath = seq[Coordinate]
    Cave = object
        obstacles: HashSet[Coordinate]
        topLeft: Coordinate
        bottomRight: Coordinate
        hasFloor: bool

const infinity: Coordinate = (int.high(), int.high())
const sandProducer: Coordinate = (500, 0)

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseCoordinate(line: string): Coordinate =
    let parts = line.split(",")
    return (parseInt(parts[0]), parseInt(parts[1]))

proc parseRockPath(line: string): RockPath =
    return line.split(" -> ").map(parseCoordinate)

proc parseProblem(input: string): seq[RockPath] =
    return input.splitLines().map(parseRockPath)

proc createCave(rockpaths: seq[RockPath], hasFloor: bool): Cave =
    var
        rocks: HashSet[Coordinate]
        minX = 500
        maxX = 500
        minY = 0
        maxY = 0

    for path in rockpaths:
        for idx in 1..<path.len():
            let fromRock = path[idx-1]
            let toRock = path[idx]
            for x in min(fromRock[0], toRock[0])..max(fromRock[0], toRock[0]):
                for y in min(fromRock[1], toRock[1])..max(fromRock[1], toRock[1]):
                    rocks.incl((x, y))

    for (x, y) in rocks:
        minX = min(minX, x)
        maxX = max(maxX, x)
        minY = min(minY, y)
        maxY = max(maxY, y)

    return Cave(
        obstacles: rocks,
        topLeft: (minX, minY),
        bottomRight: (maxX, maxY),
        hasFloor: hasFloor,
    )

proc displayCave(cave: Cave) =
    let (minX, minY) = cave.topLeft
    let (maxX, maxY) = cave.bottomRight

    var screen: seq[seq[char]] = collect:
        for y in minY..maxY: collect:
            for x in minX..maxX:
                '.'

    for (rx, ry) in cave.obstacles:
        screen[ry-minY][rx-minX] = '#'

    screen[0-minY][500-minX] = '+'

    for line in screen:
        echo line.join()

iterator simulatePath(cave: Cave, initial: Coordinate): Coordinate =
    var
        (cx, cy) = initial
        found: bool

    if initial in cave.obstacles:
        yield infinity
    else:
        yield initial
        while true:
            if cave.hasFloor and cy == cave.bottomRight[1] + 1:
                break

            found = false
            for dx in [0, -1, 1]:
                let (nx, ny) = (cx + dx, cy + 1)
                if (nx, ny) in cave.obstacles:
                    continue
                found = true
                (cx, cy) = (nx, ny)
                break

            if not found:
                break

            if (not cave.hasFloor) and cy >= cave.bottomRight[1]:
                yield infinity
                break

            yield (cx, cy)

proc lastPosition(cave: Cave, initial: Coordinate): Coordinate =
    var last: Coordinate
    for c in simulatePath(cave, initial):
        last = c
    return last

iterator sandFinalPositions(cave: var Cave): Coordinate =
    while true:
        let lastPos = lastPosition(cave, sandProducer)
        if lastPos == infinity:
            break
        yield lastPos
        cave.obstacles.incl(lastPos)

proc part1(rockpaths: seq[RockPath]): int =
    var
        cave = createCave(rockpaths, hasFloor = false)
        totalSand: int

    for _ in sandFinalPositions(cave):
        totalSand += 1

    return totalSand

proc part2(rockpaths: seq[RockPath]): int =
    var
        cave = createCave(rockpaths, hasFloor = true)
        totalSand: int

    for _ in sandFinalPositions(cave):
        totalSand += 1

    return totalSand


proc main() =
    var rockpaths = parseProblem(readInputFile())
    echo "Part 1: ", part1(rockpaths)
    echo "Part 2: ", part2(rockpaths)

main()
