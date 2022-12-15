import algorithm
import sets
import sequtils
import strutils
import sugar

type
    Coordinate = (int, int)
    Interval = (int, int)

const emptyInterval = (0, -1)

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseCoordinate(line: string): Coordinate =
    let parts = line.split(", ")
    return (parseInt(parts[0][2..^1]), parseInt(parts[1][2..^1]))

proc parseReportLine(line: string): (Coordinate, Coordinate) =
    let parts = line.split(": ")
    return (parseCoordinate(parts[0][10..^1]), parseCoordinate(parts[1][21..^1]))

proc parseProblem(input: string): seq[(Coordinate, Coordinate)] =
    return input.splitLines().map(parseReportLine)

proc manhattanDistance(a: Coordinate, b: Coordinate): int =
    return abs(a[0] - b[0]) + abs(a[1] - b[1])

proc coverageAt(sensor: Coordinate, nearestBeacon: Coordinate,
        row: int): Interval =
    let distance = manhattanDistance(sensor, nearestBeacon)
    let remaining = distance - abs(sensor[1]-row)
    if remaining < 0:
        return emptyInterval
    return (sensor[0]-remaining, sensor[0]+remaining)

iterator rowCoverage(report: seq[(Coordinate, Coordinate)],
        row: int): Interval =
    var intervals = report
        .map(pair => coverageAt(pair[0], pair[1], row))
        .filter(intr => intr != emptyInterval)
    intervals.sort()

    if intervals.len() > 0:
        var (cf, ct) = intervals[0]
        for idx in 1..<intervals.len():
            var (nf, nt) = intervals[idx]
            if nf > ct:
                yield (cf, ct)
                (cf, ct) = (nf, nt)
            ct = max(ct, nt)
        yield (cf, ct)

proc intersect(first: Interval, second: Interval): Interval =
    let start = max(first[0], second[0])
    let finish = min(first[1], second[1])
    if finish < start:
        return emptyInterval
    return (start, finish)

proc part1(report: seq[(Coordinate, Coordinate)]): int =
    var
        beaconsOnRow = report
            .filter(pair => pair[1][1] == 2000000)
            .map(pair => pair[1][0])
            .toHashSet()
            .toSeq()
        coveredPositions: int
        bIdx: int

    beaconsOnRow.sort()
    for (cf, ct) in rowCoverage(report, 2000000):
        coveredPositions += ct - cf + 1
        while bIdx < beaconsOnRow.len() and beaconsOnRow[bIdx] in cf..ct:
            coveredPositions -= 1
            bIdx += 1

    return coveredPositions

proc part2(report: seq[(Coordinate, Coordinate)]): int =
    var
        minRow: int = 4000000
        maxRow: int = 0
        minCol: int = 4000000
        maxCol: int = 0

    for (sensor, _) in report:
        minCol = min(minCol, sensor[0])
        maxCol = max(maxCol, sensor[0])
        minRow = min(minRow, sensor[1])
        maxRow = max(maxRow, sensor[1])

    for row in minRow..maxRow:
        var intervals: seq[Interval]
        for interval in rowCoverage(report, row):
            let bounded = interval.intersect((minCol, maxCol))
            if bounded != emptyInterval:
                intervals.add(interval)
        if intervals.len() > 1:
            return 4000000*(intervals[0][1]+1) + row

    return -1

proc main() =
    var report = parseProblem(readInputFile())
    echo "Part 1: ", part1(report)
    echo "Part 2: ", part2(report)

main()
