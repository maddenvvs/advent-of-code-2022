import sequtils
import strutils
import sugar

type
    InstructionKind = enum
        Noop, AddX
    Instruction = object
        case kind: InstructionKind
        of Noop:
            discard
        of AddX:
            value: int

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseInstruction(line: string): Instruction =
    let parts = line.split(" ")
    if parts.len() == 1:
        return Instruction(kind: InstructionKind.Noop)
    return Instruction(
        kind: InstructionKind.AddX,
        value: parseInt(parts[1]),
    )

proc parseProblem(input: string): seq[Instruction] =
    return input.splitLines().map(parseInstruction)

iterator simulate(instructions: seq[Instruction]): (int, int) =
    var
        cycle = 1
        regX = 1

    for instruction in instructions:
        case instruction.kind:
        of InstructionKind.Noop:
            yield (cycle, regX)
            cycle += 1
        of InstructionKind.AddX:
            yield (cycle, regX)
            cycle += 1
            yield (cycle, regX)
            cycle += 1
            regX += instruction.value

proc part1(instructions: seq[Instruction]): int =
    var
        totalStrength = 0
        nextCycle = 20

    for (cycle, regX) in simulate(instructions):
        if cycle == nextCycle:
            totalStrength += cycle * regX
            nextCycle += 40

    return totalStrength

proc part2(instructions: seq[Instruction]): string =
    var screen: array[6, array[40, char]]

    for (cycle, regX) in simulate(instructions):
        let row = (cycle-1) div 40
        let col = (cycle-1) mod 40
        if col in (regX-1)..(regx+1):
            screen[row][col] = '#'
        else:
            screen[row][col] = '.'

    return screen.map(line => line.join()).join("\n")


proc main() =
    var instructions = parseProblem(readInputFile())
    echo "Part 1: ", part1(instructions)
    echo "Part 2: \n", part2(instructions)

main()
