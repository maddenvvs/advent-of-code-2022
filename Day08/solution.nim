import sequtils
import strutils

type
    Forest = seq[seq[byte]]

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseLine(line: string): seq[byte] =
    return line.map(proc(v: char): byte = byte(parseUInt($v)))

proc parseProblem(input: string): Forest =
    return input.splitLines().map(parseLine)

proc countVisibleTrees(forest: var Forest, sr, sc, dr, dc: int): int =
    var
        m = forest.len()
        n = forest[0].len()
        cr = sr
        cc = sc
        maxHeight: int = -1
        count: int
        curHeight: int

    while cr in 0..m-1 and cc in 0..n-1:
        curHeight = int(forest[cr][cc])
        if curHeight > 9:
            curHeight -= 10

        if curHeight > maxHeight:
            maxHeight = curHeight
            if forest[cr][cc] < 10:
                forest[cr][cc] += 10
                count += 1

        cr += dr
        cc += dc

    return count

proc normalizeForest(forest: var Forest) =
    var
        m = forest.len()
        n = forest[0].len()

    for row in 0..<m:
        for col in 0..<n:
            if forest[row][col] > 9:
                forest[row][col] -= 10

proc viewingDistance(forest: Forest, sr, sc, dr, dc: int): int =
    var
        m = forest.len()
        n = forest[0].len()
        cr = sr + dr
        cc = sc + dc
        count: int = 0

    while cr in 0..m-1 and cc in 0..n-1:
        count += 1
        if forest[cr][cc] >= forest[sr][sc]:
            break
        cr += dr
        cc += dc

    return count

proc part1(forest: var Forest): int =
    var
        m = forest.len()
        n = forest[0].len()
        visibleTreesCount: int

    if m == 1 or n == 1:
        return max(m, n)

    for row in 1..<m-1:
        visibleTreesCount += countVisibleTrees(forest, row, 0, 0, 1)
        visibleTreesCount += countVisibleTrees(forest, row, n-1, 0, -1)

    for col in 1..<n-1:
        visibleTreesCount += countVisibleTrees(forest, 0, col, 1, 0)
        visibleTreesCount += countVisibleTrees(forest, m-1, col, -1, 0)

    return visibleTreesCount + 4

proc part2(forest: Forest): int =
    var
        m = forest.len()
        n = forest[0].len()
        score: int
        maxScore: int

    for row in 0..<m:
        for col in 0..<n:
            score = 1
            for (dr, dc) in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
                score *= viewingDistance(forest, row, col, dr, dc)
            maxScore = max(maxScore, score)

    return maxScore

proc main() =
    var forest = parseProblem(readInputFile())
    echo "Part 1: ", part1(forest)

    normalizeForest(forest)
    echo "Part 2: ", part2(forest)

main()
