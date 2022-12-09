import algorithm
import sequtils
import strutils
import sets

type
    Direction = enum
        Up, Right, Down, Left
    Motion = object
        direction: Direction
        amount: int
    Coordinate = (int, int)
    Rope = seq[Coordinate]

let directions: array[Direction, Coordinate] = [
    (0, 1),
    (1, 0),
    (0, -1),
    (-1, 0),
]

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseMotion(line: string): Motion =
    let parts = line.split(" ")
    let amount = parseInt(parts[1])
    case parts[0]
    of "R":
        return Motion(direction: Direction.Right, amount: amount)
    of "L":
        return Motion(direction: Direction.Left, amount: amount)
    of "U":
        return Motion(direction: Direction.Up, amount: amount)
    of "D":
        return Motion(direction: Direction.Down, amount: amount)
    else:
        discard

proc parseProblem(input: string): seq[Motion] =
    return input.splitLines().map(parseMotion)

proc isTouching(head: Coordinate, tail: Coordinate): bool =
    let (hx, hy) = head
    let (tx, ty) = tail
    return max(abs(hx-tx), abs(hy-ty)) < 2

proc adjustKnot(leader: Coordinate, follower: Coordinate): Coordinate =
    if isTouching(leader, follower):
        return follower

    let (hx, hy) = leader
    let (tx, ty) = follower
    let (dx, dy) = (hx-tx, hy-ty)

    if abs(dx) <= 1:
        if dy < 0:
            return (hx, hy+1)
        else:
            return (hx, hy-1)
    elif abs(dy) <= 1:
        if dx < 0:
            return (hx+1, hy)
        else:
            return (hx-1, hy)
    else:
        if dx > 0:
            if dy > 0:
                return (hx-1, hy-1)
            else:
                return (hx-1, hy+1)
        else:
            if dy > 0:
                return (hx+1, hy-1)
            else:
                return (hx+1, hy+1)

proc simulateMotion(rope: var Rope, direction: Direction) =
    let
        (hx, hy) = rope[0]
        (dx, dy) = directions[direction]
        newHead = (hx+dx, hy+dy)

    rope[0] = newHead
    for idx in 1..<rope.len():
        rope[idx] = adjustKnot(rope[idx-1], rope[idx])

proc drawRope(rope: Rope) =
    var minx, miny, maxx, maxy = 0
    for (x, y) in rope:
        minx = min(minx, x)
        miny = min(miny, y)
        maxx = max(maxx, x)
        maxy = max(maxy, y)

    var screen: seq[seq[char]] = @[]
    for _ in 0..(maxy-miny):
        var row: seq[char] = @[]
        for _ in 0..(maxx-minx):
            row.add('.')
        screen.add(row)

    screen[-miny][-minx] = 'S'
    let ropeLen = rope.len()
    for idx in countdown(ropelen-1, 1, 1):
        let (kx, ky) = rope[idx]
        screen[ky-miny][kx-minx] = ($idx)[0]

    let (hx, hy) = rope[0]
    screen[hy-miny][hx-minx] = 'H'

    for row in screen.reversed():
        echo row.join("")

proc tailPositions(rope: Rope, motions: seq[Motion]): seq[Coordinate] =
    var rope = rope
    var visitedCells: HashSet[Coordinate] = [(0, 0)].toHashSet()

    for motion in motions:
        for _ in 0..<motion.amount:
            rope.simulateMotion(motion.direction)
            visitedCells.incl(rope[^1])

    return visitedCells.toSeq()

proc part1(motions: seq[Motion]): int =
    let rope: Rope = @[(0, 0), (0, 0)]
    return tailPositions(rope, motions).len()

proc part2(motions: seq[Motion]): int =
    var rope: Rope = @[]
    for _ in 0..<10:
        rope.add((0, 0))
    return tailPositions(rope, motions).len()

proc main() =
    var motions = parseProblem(readInputFile())
    echo "Part 1: ", part1(motions)
    echo "Part 2: ", part2(motions)

main()
