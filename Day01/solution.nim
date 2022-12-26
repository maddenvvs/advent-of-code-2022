import strutils

proc readInputFile(): string =
    return readFile("input.txt").strip()

func parseProblem(input: string): seq[string] =
    return input.splitLines()

iterator elfCalories(calories: seq[string]): int =
    var currentCalories: int = 0

    for line in calories:
        if line == "":
            yield currentCalories
            currentCalories = 0
        else:
            currentCalories += parseInt(line)

    if currentCalories > 0:
        yield currentCalories

func part1(calories: seq[string]): int =
    var maxCalories = 0
    for elf in elfCalories(calories):
        maxCalories = max(maxCalories, elf)
    return maxCalories

func part2(calories: seq[string]): int =
    var first = 0
    var second = 0
    var third = 0

    for elf in elfCalories(calories):
        if elf >= first:
            third = second
            second = first
            first = elf
        elif elf >= second:
            third = second
            second = elf
        else:
            third = max(third, elf)

    return first + second + third

proc main() =
    let calories = parseProblem(readInputFile())
    echo "Part 1: ", part1(calories)
    echo "Part 2: ", part2(calories)

main()
