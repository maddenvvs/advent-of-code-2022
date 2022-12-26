import lists
import sequtils
import strutils
import sugar

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseProblem(input: string): seq[int] =
    return input.splitLines().map(parseInt)

proc mix(list: var DoublyLinkedRing[int], order: seq[DoublyLinkedNode[int]]) =
    let length = order.len() - 1
    for node in order:
        list.remove(node)

        var value = abs(node.value) mod length
        var beforeNode = node.prev

        for _ in 1..value:
            if node.value > 0:
                beforeNode = beforeNode.next
            else:
                beforeNode = beforeNode.prev

        node.next = beforeNode.next
        node.prev = beforeNode
        beforeNode.next.prev = node
        beforeNode.next = node

proc findGroveCoordinates(list: DoublyLinkedRing[int]): int =
    var curr = list.find(0)
    var res, idx = 0

    for position in [1000, 2000, 3000]:
        while idx < position:
            curr = curr.next
            idx += 1
        res += curr.value

    return res

proc part1(numbers: seq[int]): int =
    var list = initDoublyLinkedRing[int]()
    var nodes = numbers.map(v => newDoublyLinkedNode[int](v))
    for node in nodes:
        list.append(node)

    list.mix(nodes)

    return findGroveCoordinates(list)

proc part2(numbers: seq[int]): int =
    var list = initDoublyLinkedRing[int]()
    var nodes = numbers.map(v => newDoublyLinkedNode[int](v * 811589153))
    for node in nodes:
        list.append(node)

    for _ in 1..10:
        list.mix(nodes)

    return findGroveCoordinates(list)

proc main() =
    var numbers = parseProblem(readInputFile())
    echo "Part 1: ", part1(numbers)
    echo "Part 2: ", part2(numbers)

main()
