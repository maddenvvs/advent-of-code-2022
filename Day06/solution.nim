import strutils
import tables

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc findDistinctWindow(signal: string, size: int): int =
    var
        seen: Table[char, int]
        start: int = -1

    for index, character in signal:
        let lastPos = seen.getOrDefault(character, -1)
        let newStart = max(start, lastPos)
        if index - newStart >= size:
            return index + 1
        start = newStart
        seen[character] = index

    return -1

proc part1(signal: string): int =
    return findDistinctWindow(signal, 4)

proc part2(signal: string): int =
    return findDistinctWindow(signal, 14)

proc main() =
    let signal = readInputFile()
    echo "Part 1: ", part1(signal)
    echo "Part 2: ", part2(signal)

main()
