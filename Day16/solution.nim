import bitops
import sequtils
import strutils
import sugar
import tables

type
    ScanLine = object
        name: string
        flowRate: int
        tunnels: seq[string]
    Network = object
        valveNames: seq[string]
        flowRates: seq[int]
        neighbours: seq[seq[int]]

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseNameAndFlowRate(line: string): (string, int) =
    let parts = line.split(" ")
    return (parts[1], parseInt(parts[^1][5..^1]))

proc parseTunnels(line: string): seq[string] =
    var startOffset = 22
    if line.contains("valves"):
        startOffset = 23
    return line[startOffset..^1].split(", ")

proc parseScanLine(line: string): ScanLine =
    let halves = line.split("; ")
    let (name, flowRate) = parseNameAndFlowRate(halves[0])
    let tunnels = parseTunnels(halves[1])
    return ScanLine(
        name: name,
        flowRate: flowRate,
        tunnels: tunnels,
    )

proc parseProblem(input: string): seq[ScanLine] =
    return input.splitLines().map(parseScanLine)

proc createNetwork(report: seq[ScanLine]): Network =
    let valveNames = report.map(l => l.name)
    let flowRates = report.map(l => l.flowRate)
    let neighbours: seq[seq[int]] = collect:
        for reportLine in report: collect:
            for tunnelTo in reportLine.tunnels: valveNames.find(tunnelTo)

    return Network(
        valveNames: valveNames,
        flowRates: flowRates,
        neighbours: neighbours,
    )

proc findShortestDistances(
    network: Network,
): seq[seq[int]] =
    let n = network.neighbours.len()
    var distances = toSeq(1..n).map(_ => toSeq(1..n).map(_ => 100_000))

    for i in 0..<n:
        distances[i][i] = 0

    for u in 0..<n:
        for v in network.neighbours[u]:
            distances[u][v] = 1
            distances[v][u] = 1

    for k in 0..<n:
        for i in 0..<n:
            for j in 0..<n:
                distances[i][j] = min(
                    distances[i][j],
                    distances[i][k] + distances[k][j],
                )

    return distances

proc findMostPressure(
    network: Network,
    valves: seq[int],
    distances: seq[seq[int]],
): int =
    var cache: Table[(int, int, int), int]

    proc dp(valve: int, remainingTime: int, openedValves: int): int =
        if remainingTime <= 0:
            return 0

        let key = (valve, remainingTime, openedValves)
        let value = cache.getOrDefault(key, -1)
        if value != -1:
            return value

        var maxPressure = 0
        for nextValve in valves:
            if testBit(openedValves, nextValve):
                continue

            let newTime = remainingTime-distances[valve][nextValve]-1
            var newMask = openedValves
            setBit(newMask, nextValve)

            maxPressure = max(
                maxPressure,
                newTime * network.flowRates[nextValve] +
                    dp(nextValve, newTime, newMask)
            )

        cache[key] = maxPressure
        return maxPressure

    return dp(network.valveNames.find("AA"), 30, 0)

iterator valvePairs(valves: seq[int]): (int, int) =
    let n = valves.len()

    for i in 0..<n-1:
        for j in i+1..<n:
            yield (valves[i], valves[j])
            yield (valves[j], valves[i])

proc findMostPressureForTwo(
    network: Network,
    valves: seq[int],
    distances: seq[seq[int]],
): int =
    var cache: Table[(int, int, int, int, int), int]

    proc dp(
        firstValve: int,
        secondValve: int,
        firstTime: int,
        secondTime: int,
        openedValves: int,
    ): int =
        if firstTime <= 0 and secondTime <= 0:
            return 0

        let key = (
            firstValve,
            secondValve,
            firstTime,
            secondTime,
            openedValves,
        )
        let value = cache.getOrDefault(key, -1)
        if value != -1:
            return value

        var maxPressure = 0

        if secondTime <= 0:
            for nextValve in valves:
                if testBit(openedValves, nextValve):
                    continue

                let newTime = firstTime-distances[firstValve][nextValve]-1
                var newMask = openedValves
                setBit(newMask, nextValve)

                maxPressure = max(
                    maxPressure,
                    newTime * network.flowRates[nextValve] +
                        dp(
                            nextValve,
                            secondValve,
                            newTime,
                            secondTime,
                            newMask,
                    )
                )
        elif firstTime <= 0:
            for nextValve in valves:
                if testBit(openedValves, nextValve):
                    continue

                let newTime = secondTime-distances[secondValve][nextValve]-1
                var newMask = openedValves
                setBit(newMask, nextValve)

                maxPressure = max(
                    maxPressure,
                    newTime * network.flowRates[nextValve] +
                        dp(
                            firstValve,
                            nextValve,
                            firstTime,
                            newTime,
                            newMask,
                    )
                )
        else:
            for (nextFirst, nextSecond) in valvePairs(valves):
                if testBit(openedValves, nextFirst) or
                   testBit(openedValves, nextSecond):
                    continue

                let newFirstTime = firstTime-distances[firstValve][nextFirst]-1
                let newSecondTime = secondTime-distances[secondValve][nextSecond]-1
                var newMask = openedValves
                setBit(newMask, nextFirst)
                setBit(newMask, nextSecond)

                maxPressure = max(
                    maxPressure,
                    newFirstTime * network.flowRates[nextFirst] +
                    newSecondTime * network.flowRates[nextSecond] +
                        dp(
                            nextFirst,
                            nextSecond,
                            newFirstTime,
                            newSecondTime,
                            newMask,
                    )
                )

        cache[key] = maxPressure
        return maxPressure

    let indexOfAA = network.valveNames.find("AA")
    return dp(indexOfAA, indexOfAA, 26, 26, 0)

proc findMostPressureToRelease(network: Network): int =
    let distances = findShortestDistances(network)
    let usefulValves = network.flowRates
        .pairs().toSeq()
        .filter(p => p.val > 0)
        .map(p => p.key)

    return findMostPressure(network, usefulValves, distances)

proc findMostPressureToReleaseForTwo(network: Network): int =
    let distances = findShortestDistances(network)
    let usefulValves = network.flowRates
        .pairs().toSeq()
        .filter(p => p.val > 0)
        .map(p => p.key)

    return findMostPressureForTwo(network, usefulValves, distances)

proc part1(report: seq[ScanLine]): int =
    let network = createNetwork(report)
    return findMostPressureToRelease(network)

proc part2(report: seq[ScanLine]): int =
    let network = createNetwork(report)
    return findMostPressureToReleaseForTwo(network)

proc main() =
    var report = parseProblem(readInputFile())
    echo "Part 1: ", part1(report)
    echo "Part 2: ", part2(report)

main()
