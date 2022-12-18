import sets
import sequtils
import strutils

type
    Coordinate = (int, int, int)

let directions: array[6, Coordinate] = [
    (1, 0, 0),
    (0, 1, 0),
    (0, 0, 1),
    (-1, 0, 0),
    (0, -1, 0),
    (0, 0, -1),
]

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseCoordinate(line: string): Coordinate =
    let parts = line.split(",").map(parseInt)
    return (parts[0], parts[1], parts[2])

proc parseProblem(input: string): seq[Coordinate] =
    return input.splitLines().map(parseCoordinate)

proc traverseFigure(
    droplet: Coordinate,
    droplets: HashSet[Coordinate],
    visited: var HashSet[Coordinate],
): int =
    var totalSides: int
    var stack: seq[Coordinate] = @[droplet]
    visited.incl(droplet)

    while stack.len() > 0:
        let (cx, cy, cz) = stack.pop()
        totalSides += 6

        for (dx, dy, dz) in directions:
            let nd = (cx+dx, cy+dy, cz+dz)
            if not (nd in droplets):
                continue

            totalSides -= 1
            if nd in visited:
                continue

            visited.incl(nd)
            stack.add(nd)

    return totalSides

proc countNumberOfSides(droplets: seq[Coordinate]): int =
    let dropletsSet = droplets.toHashSet()
    var visited: HashSet[Coordinate]
    var totalSides: int

    for droplet in droplets:
        if not (droplet in visited):
            totalSides += traverseFigure(droplet, dropletsSet, visited)

    return totalSides

proc findBoundBox(droplets: seq[Coordinate]): (Coordinate, Coordinate) =
    var (minX, minY, minZ) = (int.high(), int.high(), int.high())
    var (maxX, maxY, maxZ) = (int.low(), int.low(), int.low())

    for (cx, cy, cz) in droplets:
        minX = min(minX, cx)
        minY = min(minY, cy)
        minZ = min(minZ, cz)
        maxX = max(maxX, cx)
        maxY = max(maxY, cy)
        maxZ = max(maxZ, cz)

    return (
        (minX, minY, minZ),
        (maxX, maxY, maxZ),
    )

proc countExteriorSides(
    droplets: seq[Coordinate],
    boundBox: (Coordinate, Coordinate),
): int =
    let (minCoord, maxCoord) = boundBox
    let dropletsSet = droplets.toHashSet()
    var totalSides: int
    var stack: seq[Coordinate] = @[minCoord]
    var visited: HashSet[Coordinate] = @[minCoord].toHashSet()

    while stack.len() > 0:
        let (cx, cy, cz) = stack.pop()

        for (dx, dy, dz) in directions:
            let nd = (cx+dx, cy+dy, cz+dz)

            if nd[0] < minCoord[0] or
               nd[1] < minCoord[1] or
               nd[2] < minCoord[2] or
               nd[0] > maxCoord[0] or
               nd[1] > maxCoord[1] or
               nd[2] > maxCoord[2]:
                continue

            if nd in dropletsSet:
                totalSides += 1
                continue

            if nd in visited:
                continue

            visited.incl(nd)
            stack.add(nd)

    return totalSides


proc part1(droplets: seq[Coordinate]): int =
    return countNumberOfSides(droplets)

proc part2(droplets: seq[Coordinate]): int =
    let (minCoord, maxCoord) = findBoundBox(droplets)
    let newMinCoord = (minCoord[0]-1, minCoord[1]-1, minCoord[2]-1)
    let newMaxCoord = (maxCoord[0]+1, maxCoord[1]+1, maxCoord[2]+1)

    return countExteriorSides(droplets, (newMinCoord, newMaxCoord))

proc main() =
    var droplets = parseProblem(readInputFile())
    echo "Part 1: ", part1(droplets)
    echo "Part 2: ", part2(droplets)

main()
