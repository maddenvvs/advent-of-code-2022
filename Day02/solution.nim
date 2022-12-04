import strutils

type
    Hand = enum
        Rock, Paper, Scissors
    Suggestion = enum
        X, Y, Z
    Play = tuple
        opponent: Hand
        me: Suggestion

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parseHand(hand: string): Hand =
    case hand
    of "A": return Hand.Rock
    of "B": return Hand.Paper
    of "C": return Hand.Scissors
    else: return Hand.Rock

proc parseSuggestion(hand: string): Suggestion =
    case hand
    of "X": return Suggestion.X
    of "Y": return Suggestion.Y
    of "Z": return Suggestion.Z
    else: return Suggestion.X

proc parseProblem(input: string): seq[Play] =
    var guideMoves: seq[Play] = @[]
    for line in input.splitLines():
        let parts = line.splitWhitespace()
        guideMoves.add((opponent: parseHand(parts[0]), me: parseSuggestion(
                parts[1])))
    return guideMoves

proc countScore(play: Play): int =
    case play.opponent
    of Rock:
        case play.me
        of X: return 1 + 3
        of Y: return 2 + 6
        of Z: return 3 + 0
    of Paper:
        case play.me
        of X: return 1 + 0
        of Y: return 2 + 3
        of Z: return 3 + 6
    of Scissors:
        case play.me
        of X: return 1 + 6
        of Y: return 2 + 0
        of Z: return 3 + 3

proc countScore2(play: Play): int =
    case play.opponent
    of Rock:
        case play.me
        of X: return 3 + 0
        of Y: return 1 + 3
        of Z: return 2 + 6
    of Paper:
        case play.me
        of X: return 1 + 0
        of Y: return 2 + 3
        of Z: return 3 + 6
    of Scissors:
        case play.me
        of X: return 2 + 0
        of Y: return 3 + 3
        of Z: return 1 + 6

proc part1(guide: seq[Play]): int =
    var totalScore = 0
    for play in guide:
        totalScore += countScore(play)
    return totalScore

proc part2(guide: seq[Play]): int =
    var totalScore = 0
    for play in guide:
        totalScore += countScore2(play)
    return totalScore

proc main() =
    let guide = parseProblem(readInputFile())
    echo "Part 1: ", part1(guide)
    echo "Part 2: ", part2(guide)

main()
