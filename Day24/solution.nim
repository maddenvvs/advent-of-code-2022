import sets
import sequtils
import strutils
import sugar

type
    Coordinate = (int, int)

let invalidCoordinate = (int.high(), int.high())

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseProblem(input: string): seq[seq[char]] =
    return input.splitLines().map(v => v.toSeq())

proc findBlizzards(board: seq[seq[char]]): seq[(Coordinate, Coordinate)] =
    var blizzards: seq[(Coordinate, Coordinate)]

    for r, row in board:
        for c, v in row:
            case v
            of '>': blizzards.add(((r, c), (0, 1)))
            of '<': blizzards.add(((r, c), (0, -1)))
            of 'v': blizzards.add(((r, c), (1, 0)))
            of '^': blizzards.add(((r, c), (-1, 0)))
            else: continue

    return blizzards

proc findMinimalPathTime(
    board: seq[seq[char]],
    start: Coordinate,
    finish: Coordinate,
    movesElapsed: int,
): int =
    let m = board.len()
    let n = board[0].len()
    let blizzards = findBlizzards(board)

    proc findNextPositions(current: Coordinate): array[5, Coordinate] =
        let (cr, cc) = current
        var nxtPos = [
            (cr - 1, cc),
            (cr, cc - 1),
            (cr + 1, cc),
            (cr, cc + 1),
            (cr, cc),
        ]

        for idx in 0..4:
            let (nr, nc) = nxtPos[idx]
            if nr < 0 or nr >= m or nc < 0 or nc >= n or board[nr][nc] == '#':
                nxtPos[idx] = invalidCoordinate

        return nxtPos

    proc findBlizzardPosition(
        origin: Coordinate,
        direction: Coordinate,
        moves: int,
    ): Coordinate =
        var moves = moves
        let (cr, cc) = origin
        let (dr, dc) = direction
        let nr = ((((cr-1) + dr*moves) mod (m-2)) + m-2) mod (m-2) + 1
        let nc = ((((cc-1) + dc*moves) mod (n-2)) + n-2) mod (n-2) + 1
        return (nr, nc)

    var queue = @[start].toHashSet()
    var newQueue: HashSet[Coordinate]
    var moves = movesElapsed
    while true:
        for cp in queue:
            if cp == finish:
                return moves

            var nextPositions = findNextPositions(cp)
            for (blzOrig, blzDir) in blizzards:
                let blizzardPos = findBlizzardPosition(blzOrig, blzDir, moves + 1)
                let npIdx = nextPositions.find(blizzardPos)
                if npIdx != -1:
                    nextPositions[npIdx] = invalidCoordinate

            for nextPos in nextPositions:
                if nextPos != invalidCoordinate:
                    newQueue.incl(nextPos)

        queue = newQueue
        newQueue.clear()
        moves += 1

    return -1

proc part1(board: seq[seq[char]]): int =
    let start = (0, board[0].find('.'))
    let finish = (board.len()-1, board[^1].find('.'))
    return findMinimalPathTime(board, start, finish, 0)

proc part2(board: seq[seq[char]]): int =
    let coords = [
        (0, board[0].find('.')),
        (board.len()-1, board[^1].find('.')),
    ]

    var time = 0
    for round in 0..2:
        time = findMinimalPathTime(
            board,
            coords[round mod 2],
            coords[(round + 1) mod 2],
            time,
        )

    return time

proc main() =
    var board = parseProblem(readInputFile())
    echo "Part 1: ", part1(board)
    echo "Part 2: ", part2(board)

main()
