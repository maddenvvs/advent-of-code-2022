import strutils

type
    Section = tuple
        s: int
        e: int
    Pair = (Section, Section)

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseSection(line: string): Section =
    let parts = line.split("-")
    return (s: parseInt(parts[0]), e: parseInt(parts[1]))

proc parsePair(line: string): Pair =
    let parts = line.split(",")
    return (parseSection(parts[0]), parseSection(parts[1]))

proc parseProblem(input: string): seq[Pair] =
    var pairs: seq[Pair]
    for line in input.splitLines():
        pairs.add(parsePair(line))
    return pairs

proc contains(first: Section, second: Section): bool =
    return first.s <= second.s and second.e <= first.e

proc overlaps(first: Section, second: Section): bool =
    return first.s <= second.s and first.e >= second.s or
        second.s <= first.s and second.e >= first.s

proc part1(pairs: seq[Pair]): int =
    var fullyContained = 0
    for pair in pairs:
        if contains(pair[0], pair[1]) or contains(pair[1], pair[0]):
            fullyContained += 1
    return fullyContained

proc part2(pairs: seq[Pair]): int =
    var overlapped = 0
    for pair in pairs:
        if overlaps(pair[0], pair[1]):
            overlapped += 1
    return overlapped

proc main() =
    let pairs = parseProblem(readInputFile())
    echo "Part 1: ", part1(pairs)
    echo "Part 2: ", part2(pairs)

main()
