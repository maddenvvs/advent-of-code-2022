import sets
import strutils

const ASCIILetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

type
    Rucksack = tuple
        content: string

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseProblem(input: string): seq[Rucksack] =
    var rucksacks: seq[Rucksack] = @[]
    for line in input.splitLines():
        rucksacks.add((content: line))
    return rucksacks

proc findCommonItem(contents: varargs[string]): char =
    var commonItems = ASCIILetters.toHashSet()
    for content in contents:
        commonItems = commonItems.intersection(content.toHashSet())
    return commonItems.pop()

proc calculatePriority(item: char): int =
    if item.isLowerAscii():
        return int(item) - int('a') + 1
    return int(item) - int('A') + 27

proc part1(rucksacks: seq[Rucksack]): int =
    var prioritySum = 0
    for rucksack in rucksacks:
        let rucksackSize = rucksack.content.len()
        let commonItem = findCommonItem(
            rucksack.content.substr(0, rucksackSize div 2 - 1),
            rucksack.content.substr(rucksackSize div 2, rucksackSize),
        )
        prioritySum += calculatePriority(commonItem)
    return prioritySum

proc part2(rucksacks: seq[Rucksack]): int =
    let totalRucksacks = rucksacks.len()

    var prioritySum = 0
    for i in 0 ..< totalRucksacks div 3:
        let commonItem = findCommonItem(
            rucksacks[3*i].content,
            rucksacks[3*i+1].content,
            rucksacks[3*i+2].content,
        )
        prioritySum += calculatePriority(commonItem)

    return prioritySum

proc main() =
    let rucksacks = parseProblem(readInputFile())
    echo "Part 1: ", part1(rucksacks)
    echo "Part 2: ", part2(rucksacks)

main()
