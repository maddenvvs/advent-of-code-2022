import algorithm
import math
import sequtils
import strutils

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseProblem(input: string): seq[string] =
    return input.splitLines()

proc parseSNAFU(line: string): int =
    var number = 0
    var power = 1
    for idx in countdown(line.len()-1, 0, 1):
        case line[idx]
        of '2': number += 2 * power
        of '1': number += power
        of '-': number -= power
        of '=': number -= 2 * power
        else: discard
        power *= 5
    return number

proc toSNAFU(number: int): string =
    var number = number
    var digits: seq[char]

    while number > 0:
        var remainder = number mod 5
        case remainder
        of 3:
            digits.add('=')
            remainder = -2
        of 4:
            digits.add('-')
            remainder = -1
        else:
            digits.add(($remainder)[0])
        number = (number - remainder) div 5

    digits.reverse()
    return digits.join()

proc part1(numbers: seq[string]): string =
    return numbers
        .map(parseSNAFU)
        .sum()
        .toSNAFU()

proc part2(numbers: seq[string]): string =
    "Congratulations!!! You did it! Happy Christmas!"

proc main() =
    let numbers = parseProblem(readInputFile())
    echo "Part 1: ", part1(numbers)
    echo "Part 2: ", part2(numbers)

main()
