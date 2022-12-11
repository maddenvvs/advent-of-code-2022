import deques
import sets
import sequtils
import strutils
import sugar
import tables

type
    OperationKind = enum
        Add, Multiply
    Operation = object
        kind: OperationKind
        value: string
    Test = object
        divisibleBy: int
        trueMonkey: int
        falseMonkey: int
    BagItem = Table[int, int]
    Monkey = object
        items: Deque[int]
        reminders: Deque[BagItem]
        operation: Operation
        test: Test

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseStartingItems(line: string): Deque[int] =
    return line.split(": ")[1].split(", ").map(parseInt).toDeque()

proc parseOperation(line: string): Operation =
    let parts = line.split(" old ")[1].split(" ")
    if parts[0] == "*":
        return Operation(
            kind: OperationKind.Multiply,
            value: parts[1]
        )
    else:
        return Operation(
            kind: OperationKind.Add,
            value: parts[1]
        )

proc parseTest(lines: seq[string]): Test =
    return Test(
        divisibleBy: parseInt(lines[0].split(" ")[^1]),
        trueMonkey: parseInt(lines[1].split(" ")[^1]),
        falseMonkey: parseInt(lines[2].split(" ")[^1]),
    )


proc parseMonkey(monkeyStr: string): Monkey =
    let lines = monkeyStr.splitLines()
    return Monkey(
        items: parseStartingItems(lines[1]),
        operation: parseOperation(lines[2]),
        test: parseTest(lines[3..5]),
    )

proc parseProblem(input: string): seq[Monkey] =
    var monkeys = input.split("\n\n").map(parseMonkey)
    let uniqueReminders = monkeys.map(m => m.test.divisibleBy).toHashSet()

    for monkey in monkeys.mitems():
        for item in monkey.items:
            var bagItem: BagItem
            for reminder in uniqueReminders:
                bagItem[reminder] = item mod reminder
            monkey.reminders.addLast(bagItem)

    return monkeys

proc decides(monkey: Monkey, item: int): (int, int) =
    var item = item

    var operand: int
    if monkey.operation.value == "old":
        operand = item
    else:
        operand = parseInt(monkey.operation.value)

    if monkey.operation.kind == OperationKind.Add:
        item += operand
    else:
        item *= operand

    item = item div 3
    if item mod monkey.test.divisibleBy == 0:
        return (monkey.test.trueMonkey, item)
    else:
        return (monkey.test.falseMonkey, item)

proc decidesV2(monkey: Monkey, item: var BagItem): int =
    if monkey.operation.value == "old":
        if monkey.operation.kind == OperationKind.Add:
            for remainder in item.keys():
                item[remainder] = (item[remainder] * 2) mod remainder
        else:
            for remainder in item.keys():
                item[remainder] = (item[remainder] * item[
                        remainder]) mod remainder
    else:
        let operand = parseInt(monkey.operation.value)
        if monkey.operation.kind == OperationKind.Add:
            for remainder in item.keys():
                item[remainder] = (item[remainder] + operand) mod remainder
        else:
            for remainder in item.keys():
                item[remainder] = (item[remainder] * operand) mod remainder

    if item[monkey.test.divisibleBy] == 0:
        return monkey.test.trueMonkey
    else:
        return monkey.test.falseMonkey

proc simulateTurn(monkey: var Monkey, monkeys: var seq[Monkey]) =
    while monkey.items.len() > 0:
        let nextItem = monkey.items.popFirst()
        let (toMonkey, worryLevel) = decides(monkey, nextItem)
        monkeys[toMonkey].items.addLast(worryLevel)

proc simulateTurnV2(monkey: var Monkey, monkeys: var seq[Monkey]) =
    while monkey.reminders.len() > 0:
        var nextItem = monkey.reminders.popFirst()
        let toMonkey = decidesV2(monkey, nextItem)
        monkeys[toMonkey].reminders.addLast(nextItem)

proc monkeyBusiness(itemsThrown: seq[int]): int =
    var first, second = 0
    for num in itemsThrown:
        if num >= first:
            second = first
            first = num
        else:
            second = max(second, num)
    return first * second

proc part1(monkeys: var seq[Monkey]): int =
    var itemsThrown = toSeq(0..<monkeys.len()).map(el => 0)

    for _ in 1..20:
        for (idx, monkey) in monkeys.mpairs():
            itemsThrown[idx] += monkey.items.len()
            simulateTurn(monkey, monkeys)

    return monkeyBusiness(itemsThrown)

proc part2(monkeys: var seq[Monkey]): int =
    var itemsThrown = toSeq(0..<monkeys.len()).map(el => 0)

    for _ in 1..10000:
        for (idx, monkey) in monkeys.mpairs():
            itemsThrown[idx] += monkey.reminders.len()
            simulateTurnV2(monkey, monkeys)

    return monkeyBusiness(itemsThrown)

proc main() =
    var inputFile = readInputFile()
    var monkeys = parseProblem(inputFile)
    echo "Part 1: ", part1(monkeys)

    monkeys = parseProblem(inputFile)
    echo "Part 2: ", part2(monkeys)

main()
