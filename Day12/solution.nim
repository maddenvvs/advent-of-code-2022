import deques
import sequtils
import strutils
import sugar

type
    Coordinate = (int, int)
    Heightmap = seq[seq[char]]

let directions: array[4, Coordinate] = [
    (0, 1),
    (1, 0),
    (0, -1),
    (-1, 0),
]

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseProblem(input: string): Heightmap =
    return input.splitLines().map(l => l.toSeq())

proc heightOf(value: char): int =
    return case value:
        of 'S': ord('a')
        of 'E': ord('z')
        else: ord(value)

proc findDistance(heightmap: Heightmap,
    initialPositions: seq[Coordinate]): int =
    var
        m = len(heightmap)
        n = len(heightmap[0])
        visited = toSeq(1..m).map(_ => toSeq(1..n).map(_ => false))
        queue: Deque[(Coordinate, int)]

    for (cr, cc) in initialPositions:
        queue.addLast(((cr, cc), 0))
        visited[cr][cc] = true

    while queue.len() > 0:
        let (ccoord, dist) = queue.popFirst()
        let (cr, cc) = ccoord

        if heightmap[cr][cc] == 'E':
            return dist

        for (dr, dc) in directions:
            let (nr, nc) = (cr+dr, cc+dc)
            if nr < 0 or nr >= m or nc < 0 or nc >= n:
                continue
            if visited[nr][nc]:
                continue

            let heightDiff = heightOf(heightmap[nr][nc]) -
                heightOf(heightmap[cr][cc])
            if heightDiff > 1:
                continue

            visited[nr][nc] = true
            queue.addLast(((nr, nc), dist + 1))

    return -1

proc part1(heightmap: Heightmap): int =
    let initialPositions = collect:
        for r, row in heightmap:
            for c, v in row:
                if v == 'S': (r, c)
    return findDistance(heightmap, initialPositions)

proc part2(heightmap: Heightmap): int =
    let initialPositions = collect:
        for r, row in heightmap:
            for c, v in row:
                if v == 'S' or v == 'a': (r, c)
    return findDistance(heightmap, initialPositions)

proc main() =
    var heightmap = parseProblem(readInputFile())
    echo "Part 1: ", part1(heightmap)
    echo "Part 2: ", part2(heightmap)

main()
