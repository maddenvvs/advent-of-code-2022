import sequtils
import strutils
import sugar
import tables

type
    MoveKind = enum
        Number, Rotation
    Rotate = enum
        ToLeft, ToRight
    Move = object
        case kind: MoveKind
        of MoveKind.Number:
            value: int
        of MoveKind.Rotation:
            rotate: Rotate
    Direction = enum
        Right, Down, Left, Up
    State = object
        row: int
        col: int
        dir: Direction

let allDirections = [Right, Down, Left, Up]
let allDiffs = [(0, 1), (1, 0), (0, -1), (-1, 0)]

proc readInputFile(): string =
    return readFile("input.txt")

proc parseMoves(line: string): seq[Move] =
    var moves: seq[Move]
    var number: int

    for ch in line:
        if ch.isDigit():
            number = 10 * number + parseInt($ch)
        else:
            if number != 0:
                moves.add(Move(
                    kind: MoveKind.Number,
                    value: number,
                ))
                number = 0

            if ch == 'R':
                moves.add(Move(
                    kind: MoveKind.Rotation,
                    rotate: Rotate.ToRight,
                ))
            else:
                moves.add(Move(
                    kind: MoveKind.Rotation,
                    rotate: Rotate.ToLeft,
                ))

    if number != 0:
        moves.add(Move(
            kind: MoveKind.Number,
            value: number,
        ))

    return moves

proc parseProblem(input: string): (seq[seq[char]], seq[Move]) =
    let halves = input.split("\n\n")
    let board = halves[0].splitLines().map(l => l.toSeq())
    return (board, parseMoves(halves[1]))

proc opposite(dir: Direction): Direction =
    let n = allDirections.len()
    return allDirections[(allDirections.find(dir) + 2) mod n]

proc rectangify(board: var seq[seq[char]]) =
    var maxWidth = 0
    for row in board:
        maxWidth = max(maxWidth, row.len())

    for row in board.mitems():
        for _ in 1..(maxWidth - row.len()):
            row.add(' ')

proc initState(row: int, col: int): State =
    return State(
        row: row,
        col: col,
        dir: Direction.Right
    )

proc rotate(state: State, rotate: Rotate): State =
    let n = allDirections.len()
    let dirIdx = allDirections.find(state.dir)
    let diff = (if rotate == ToLeft: -1 else: 1)
    let newDir = allDirections[(dirIdx + diff + n) mod n]

    return State(
        row: state.row,
        col: state.col,
        dir: newDir,
    )

proc assignPosition(state: State, row: int, col: int): State =
    return State(
        row: row,
        col: col,
        dir: state.dir,
    )

proc nextPosition(state: State): (int, int) =
    let (cr, cc) = (state.row, state.col)
    let (dr, dc) = allDiffs[allDirections.find(state.dir)]
    return (cr + dr, cc + dc)

proc countFinalPassword(state: State): int =
    return 1000*(state.row+1) +
        4*(state.col+1) +
        allDirections.find(state.dir)

proc part1(board: var seq[seq[char]], moves: seq[Move]): int =
    rectangify(board)
    let m = board.len()
    let n = board[0].len()

    var currentState = initState(0, board[0].find('.'))
    for move in moves:
        case move.kind
        of MoveKind.Rotation:
            currentState = currentState.rotate(move.rotate)
        of MoveKind.Number:
            for _ in 1..move.value:
                var (nr, nc) = currentState.nextPosition()

                if nr < 0 or nr >= m or nc < 0 or nc >= n or board[nr][nc] == ' ':
                    let dr = nr - currentState.row
                    let dc = nc - currentState.col
                    nr = (nr + m) mod m
                    nc = (nc + n) mod n

                    while board[nr][nc] == ' ':
                        nr = (nr + dr + m) mod m
                        nc = (nc + dc + n) mod n

                if board[nr][nc] == '#':
                    break

                currentState = currentState.assignPosition(nr, nc)

    return countFinalPassword(currentState)

proc part2(board: var seq[seq[char]], moves: seq[Move]): int =
    rectangify(board)
    let m = board.len()
    let n = board[0].len()

    proc mirrorRow(c: (int, int)): (int, int) {.closure.} =
        return (49-c[0], c[1])

    proc swapCoordinates(c: (int, int)): (int, int) {.closure.} =
        return (c[1], c[0])

    proc identity(c: (int, int)): (int, int) {.closure.} =
        return c

    var regionNeigbours: Table[
            (int, Direction),
            (int, Direction, proc(c: (int, int)): (int, int))
        ]
    regionNeigbours[(1, Left)] = (6, Left, mirrorRow)
    regionNeigbours[(1, Up)] = (9, Left, swapCoordinates)
    regionNeigbours[(2, Up)] = (9, Down, identity)
    regionNeigbours[(2, Right)] = (7, Right, mirrorRow)
    regionNeigbours[(2, Down)] = (4, Right, swapCoordinates)
    regionNeigbours[(4, Left)] = (6, Up, swapCoordinates)
    regionNeigbours[(4, Right)] = (2, Down, swapCoordinates)
    regionNeigbours[(6, Left)] = (1, Left, mirrorRow)
    regionNeigbours[(6, Up)] = (4, Left, swapCoordinates)
    regionNeigbours[(7, Right)] = (2, Right, mirrorRow)
    regionNeigbours[(7, Down)] = (9, Right, swapCoordinates)
    regionNeigbours[(9, Right)] = (7, Down, swapCoordinates)
    regionNeigbours[(9, Down)] = (2, Up, identity)
    regionNeigbours[(9, Left)] = (1, Up, swapCoordinates)

    proc regionId(row: int, col: int): int =
        let rr = row div 50
        let rc = col div 50
        return rr * (n div 50) + rc

    proc startOfRegion(region: int): (int, int) =
        let regionsPerRow = n div 50
        let regionRow = region div regionsPerRow
        let regionCol = region mod regionsPerRow
        return (50*regionRow, 50*regionCol)

    proc findRegionTo(regionFrom: int, dir: Direction):
        (int, Direction, proc(c: (int, int)): (int, int)) =
        return regionNeigbours[(regionFrom, dir)]

    proc borderStartOfRegion(region: int, borderDir: Direction): (int, int) =
        let (r, c) = startOfRegion(region)
        return case borderDir
            of Right: (r, c+49)
            of Down: (r+49, c)
            else: (r, c)

    proc handleCubicWrap(state: State): (int, int, Direction) =
        let cr = state.row
        let cc = state.col

        let regionFrom = regionId(cr, cc)
        let (regionTo, borderPosition, coordinateMapping) =
            findRegionTo(regionFrom, state.dir)

        let (bfr, bfc) = borderStartOfRegion(regionFrom, state.dir)
        let (btr, btc) = borderStartOfRegion(regionTo, borderPosition)
        let (ndr, ndc) = coordinateMapping((cr - bfr, cc - bfc))

        return (btr+ndr, btc+ndc, borderPosition.opposite())

    var currentState = initState(0, board[0].find('.'))
    for move in moves:
        case move.kind
        of MoveKind.Rotation:
            currentState = currentState.rotate(move.rotate)
        of MoveKind.Number:
            for _ in 1..move.value:
                var (nr, nc) = currentState.nextPosition()
                var direction = currentState.dir

                if nr < 0 or nr >= m or nc < 0 or nc >= n or board[nr][nc] == ' ':
                    (nr, nc, direction) = handleCubicWrap(currentState)

                if board[nr][nc] == '#':
                    break

                currentState = State(
                    row: nr,
                    col: nc,
                    dir: direction,
                )

    return countFinalPassword(currentState)

proc main() =
    var (board, moves) = parseProblem(readInputFile())
    echo "Part 1: ", part1(board, moves)
    echo "Part 2: ", part2(board, moves)

main()
