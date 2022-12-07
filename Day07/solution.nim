import sequtils
import strutils
import tables

type
    OutputKind = enum
        cd,
        ls,
        dir,
        file
    Output = object
        case kind: OutputKind
        of cd:
            directory: string
        of ls:
            discard
        of dir:
            directoryName: string
        of file:
            filename: string
            size: int
    FileType = enum
        Directory, File
    FileNode = ref object
        size: int
        name: string
        case kind: FileType
        of Directory:
            children: Table[string, FileNode]
        of File:
            discard

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseOutput(line: string): Output =
    let parts = line.split(" ")
    if parts[0] == "$":
        if parts[1] == "ls":
            return Output(kind: OutputKind.ls)
        else:
            return Output(kind: OutputKind.cd, directory: parts[2])
    if parts[0] == "dir":
        return Output(kind: OutputKind.dir, directoryName: parts[1])
    else:
        return Output(
            kind: OutputKind.file,
            size: parseInt(parts[0]),
            filename: parts[1],
        )

proc parseProblem(input: string): seq[Output] =
    return input.splitLines().map(parseOutput)

proc restoreSize(node: FileNode): int =
    if node.kind == FileType.Directory:
        for child in node.children.values:
            node.size += restoreSize(child)
    return node.size

proc restoreFileTree(output: seq[Output]): FileNode =
    var fakeHead = FileNode(kind: FileType.Directory)
    fakeHead.children["/"] = FileNode(kind: FileType.Directory, name: "/")
    var stack: seq[FileNode] = @[fakeHead]

    for outputLine in output:
        case outputLine.kind:
        of ls:
            discard
        of cd:
            if outputLine.directory == "..":
                discard stack.pop()
            else:
                stack.add(stack[^1].children[outputLine.directory])
        of dir:
            stack[^1].children[outputLine.directoryName] = FileNode(
                kind: FileType.Directory,
                name: outputLine.directoryName,
            )
        of file:
            stack[^1].children[outputLine.filename] = FileNode(
                kind: FIleType.File,
                name: outputLine.filename,
                size: outputLine.size,
            )

    let root = fakeHead.children["/"]
    discard restoreSize(root)
    return root

iterator directories(node: FileNode): FileNode =
    var stack: seq[FileNode] = @[node]
    while stack.len() > 0:
        let curr = stack.pop()
        yield curr
        for child in curr.children.values:
            if child.kind == FileType.Directory:
                stack.add(child)

proc part1(output: seq[Output]): int =
    let fileTree = restoreFileTree(output)
    var totalSize = 0
    for directory in fileTree.directories():
        if directory.size <= 100_000:
            totalSize += directory.size
    return totalSize

proc part2(output: seq[Output]): int =
    let fileTree = restoreFileTree(output)

    let spaceToFree: int = 30_000_000 - (70_000_000 - fileTree.size)
    var bestDiff = 30_000_000
    for directory in fileTree.directories():
        if directory.size > spaceToFree:
            bestDiff = min(bestDiff, directory.size - spaceToFree)
    return spaceToFree + bestDiff

proc main() =
    let output = parseProblem(readInputFile())
    echo "Part 1: ", part1(output)
    echo "Part 2: ", part2(output)

main()
