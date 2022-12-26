import sequtils
import strutils
import sugar
import tables

type
    MonkeyKind = enum
        Number, Operation
    OperationKind = enum
        Add, Subtract, Multiply, Divide
    Monkey = ref object
        name: string
        case kind: MonkeyKind
        of Number:
            value: int
        else:
            operation: OperationKind
            monkeys: array[2, string]
    Node = ref object
        name: string
        case kind: MonkeyKind
        of Number:
            value: int
        else:
            operation: OperationKind
            nodes: array[2, Node]

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseMonkey(line: string): Monkey =
    let halves = line.split(": ")
    let name = halves[0]

    let operation = halves[1].split(" ")
    if operation.len() == 1:
        return Monkey(
            name: name,
            kind: MonkeyKind.Number,
            value: parseInt(operation[0]),
        )

    let operationType = case operation[1]
        of "+": OperationKind.Add
        of "-": OperationKind.Subtract
        of "*": OperationKind.Multiply
        else: OperationKind.Divide

    return Monkey(
        name: name,
        kind: MonkeyKind.Operation,
        operation: operationType,
        monkeys: [operation[0], operation[2]],
    )

proc parseProblem(input: string): seq[Monkey] =
    return input.splitLines().map(parseMonkey)

proc buildOperationTree(monkeys: seq[Monkey]): Node =
    var monkeysTable: TableRef[string, Monkey] = newTable[string, Monkey]()
    for monkey in monkeys:
        monkeysTable[monkey.name] = monkey

    proc restoreTree(name: string): Node =
        let monkey = monkeysTable[name]

        if monkey.kind == MonkeyKind.Number:
            return Node(
                name: monkey.name,
                kind: MonkeyKind.Number,
                value: monkey.value,
            )

        return Node(
            name: monkey.name,
            kind: MonkeyKind.Operation,
            operation: monkey.operation,
            nodes: [
                restoreTree(monkey.monkeys[0]),
                restoreTree(monkey.monkeys[1]),
            ]
        )

    return restoreTree("root")

proc evaluate(node: Node): int =
    if node.kind == MonkeyKind.Number:
        return node.value

    let first = evaluate(node.nodes[0])
    let second = evaluate(node.nodes[1])

    return case node.operation
        of OperationKind.Add: first + second
        of OperationKind.Subtract: first - second
        of OperationKind.Multiply: first * second
        else: first div second

proc buildPathToHuman(node: Node): seq[bool] =
    var path: seq[bool]

    proc buildPath(current: Node): bool =
        if current.name == "humn":
            return true

        if current.kind == MonkeyKind.Number:
            return false

        if buildPath(current.nodes[0]):
            path.add(true)
            return true

        if buildPath(current.nodes[1]):
            path.add(false)
            return true

        return false

    discard buildPath(node)
    return path

proc findHumanValue(node: Node, path: seq[bool]): int =

    proc buildSolution(left: Node, right: Node, idx: int): Node =
        if idx == 0:
            if path[idx]:
                return right
            else:
                return left

        if path[idx]:
            case left.operation
            of OperationKind.Add:
                if path[idx-1]:
                    return buildSolution(
                        left.nodes[0],
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Subtract,
                            nodes: [
                                right,
                                left.nodes[1],
                        ],
                    ),
                        idx-1,
                    )
                else:
                    return buildSolution(
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Subtract,
                            nodes: [
                                right,
                                left.nodes[0],
                        ]),
                        left.nodes[1],
                        idx-1,
                    )
            of OperationKind.Subtract:
                if path[idx-1]:
                    return buildSolution(
                        left.nodes[0],
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Add,
                            nodes: [
                                right,
                                left.nodes[1],
                        ],
                    ),
                        idx-1,
                    )
                else:
                    return buildSolution(
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Subtract,
                            nodes: [
                                left.nodes[0],
                                right,
                        ]),
                        left.nodes[1],
                        idx-1,
                    )
            of OperationKind.Multiply:
                if path[idx-1]:
                    return buildSolution(
                        left.nodes[0],
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Divide,
                            nodes: [
                                right,
                                left.nodes[1],
                        ],
                    ),
                        idx-1,
                    )
                else:
                    return buildSolution(
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Divide,
                            nodes: [
                                right,
                                left.nodes[0],
                        ]),
                        left.nodes[1],
                        idx-1,
                    )
            of OperationKind.Divide:
                if path[idx-1]:
                    return buildSolution(
                        left.nodes[0],
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Multiply,
                            nodes: [
                                right,
                                left.nodes[1],
                        ],
                    ),
                        idx-1,
                    )
                else:
                    return buildSolution(
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Divide,
                            nodes: [
                                left.nodes[0],
                                right,
                        ]),
                        left.nodes[1],
                        idx-1,
                    )
        else:
            case right.operation
            of OperationKind.Add:
                if path[idx-1]:
                    return buildSolution(
                        right.nodes[0],
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Subtract,
                            nodes: [
                                left,
                                right.nodes[1],
                        ],
                    ),
                        idx-1,
                    )
                else:
                    return buildSolution(
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Subtract,
                            nodes: [
                                left,
                                right.nodes[0],
                        ]),
                        right.nodes[1],
                        idx-1,
                    )
            of OperationKind.Subtract:
                if path[idx-1]:
                    return buildSolution(
                        right.nodes[0],
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Add,
                            nodes: [
                                left,
                                right.nodes[1],
                        ],
                    ),
                        idx-1,
                    )
                else:
                    return buildSolution(
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Subtract,
                            nodes: [
                                right.nodes[0],
                                left,
                        ]),
                        right.nodes[1],
                        idx-1,
                    )
            of OperationKind.Multiply:
                if path[idx-1]:
                    return buildSolution(
                        right.nodes[0],
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Divide,
                            nodes: [
                                left,
                                right.nodes[1],
                        ],
                    ),
                        idx-1,
                    )
                else:
                    return buildSolution(
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Divide,
                            nodes: [
                                left,
                                right.nodes[0],
                        ]),
                        right.nodes[1],
                        idx-1,
                    )
            of OperationKind.Divide:
                if path[idx-1]:
                    return buildSolution(
                        right.nodes[0],
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Multiply,
                            nodes: [
                                left,
                                right.nodes[1],
                        ],
                    ),
                        idx-1,
                    )
                else:
                    return buildSolution(
                        Node(
                            kind: MonkeyKind.Operation,
                            operation: OperationKind.Divide,
                            nodes: [
                                right.nodes[0],
                                left,
                        ]),
                        right.nodes[1],
                        idx-1,
                    )

    return evaluate(buildSolution(node.nodes[0], node.nodes[1], path.len()-1))

proc part1(monkeys: seq[Monkey]): int =
    let tree = buildOperationTree(monkeys)
    return evaluate(tree)

proc part2(monkeys: seq[Monkey]): int =
    let tree = buildOperationTree(monkeys)
    let humanPath = buildPathToHuman(tree)
    return findHumanValue(tree, humanPath)

proc main() =
    let monkeys = parseProblem(readInputFile())
    echo "Part 1: ", part1(monkeys)
    echo "Part 2: ", part2(monkeys)

main()
