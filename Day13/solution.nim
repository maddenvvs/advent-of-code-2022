import algorithm
import strutils

type
    DataKind = enum
        Integer, List
    PacketData = ref object
        case kind: DataKind
        of Integer:
            value: int
        of List:
            values: seq[PacketData]
    CompareResult = enum
        Less, Equal, More

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parsePacketData(line: string): PacketData =
    var
        stack: seq[PacketData] = @[PacketData(kind: DataKind.List, values: @[])]
        currentNumber: int = -1

    for ch in line:
        case ch
        of '[':
            let value = PacketData(kind: DataKind.List, values: @[])
            stack[^1].values.add(value)
            stack.add(value)
        of ']':
            if currentNumber != -1:
                stack[^1].values.add(PacketData(
                    kind: DataKind.Integer,
                    value: currentNumber,
                ))
                currentNumber = -1
            discard stack.pop()
        of ',':
            stack[^1].values.add(PacketData(
                kind: DataKind.Integer,
                value: currentNumber,
            ))
            currentNumber = -1
        else:
            if currentNumber == -1:
                currentNumber = parseInt($ch)
            else:
                currentNumber = 10 * currentNumber + parseInt($ch)

    assert stack.len() == 1
    return stack[0].values[0]

proc parseProblem(input: string): seq[PacketData] =
    var packets: seq[PacketData]
    for pair in input.split("\n\n"):
        let parts = pair.splitLines()
        packets.add(parsePacketData(parts[0]))
        packets.add(parsePacketData(parts[1]))
    return packets

proc compare(first: int, second: int): CompareResult =
    if first < second:
        return CompareResult.Less
    if first > second:
        return CompareResult.More
    return CompareResult.Equal

proc compare(first: PacketData, second: PacketData): CompareResult =
    if first.kind == DataKind.Integer:
        if second.kind == DataKind.Integer:
            return compare(first.value, second.value)
        else:
            return compare(PacketData(kind: DataKind.List, values: @[first]), second)
    else:
        if second.kind == DataKind.Integer:
            return compare(first, PacketData(kind: DataKind.List, values: @[second]))
        else:
            let commonSize = min(first.values.len(), second.values.len())
            for i in 0..<commonSize:
                let res = compare(first.values[i], second.values[i])
                if res != CompareResult.Equal:
                    return res
            return compare(first.values.len(), second.values.len())

proc createDividerPacket(value: int): PacketData =
    return PacketData(kind: DataKind.List, values: @[
            PacketData(kind: DataKind.List, values: @[
                PacketData(kind: DataKind.Integer, value: value)
        ])
    ])

proc packetComparator(left: PacketData, right: PacketData): int =
    return case compare(left, right)
        of Equal: 0
        of Less: -1
        of More: 1

proc part1(packets: seq[PacketData]): int =
    var total: int
    for idx in 0..<packets.len() div 2:
        if compare(packets[2*idx], packets[2*idx+1]) == CompareResult.Less:
            total += idx + 1
    return total

proc part2(packets: var seq[PacketData]): int =
    let dividerPackets = [createDividerPacket(2), createDividerPacket(6)]

    for dividerPacket in dividerPackets:
        packets.add(dividerPacket)
    packets.sort(packetComparator)

    var total: int = 1
    for dividerPacket in dividerPackets:
        total *= packets.find(dividerPacket) + 1
    return total

proc main() =
    var packets = parseProblem(readInputFile())
    echo "Part 1: ", part1(packets)
    echo "Part 2: ", part2(packets)

main()
