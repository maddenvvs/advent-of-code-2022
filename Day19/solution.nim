import sets
import sequtils
import strutils
import sugar

type
    ResourceAmount = tuple
        ore: int
        clay: int
        obsidian: int
        geode: int
    Blueprint = object
        id: int
        robots: array[4, ResourceAmount]
    SimulationState = tuple
        resources: ResourceAmount
        robots: ResourceAmount

let robotIncrease: array[4, ResourceAmount] = [
    (1, 0, 0, 0),
    (0, 1, 0, 0),
    (0, 0, 1, 0),
    (0, 0, 0, 1),
]

proc readInputFile(): string =
    return readFile("input.txt").strip()

proc parsePrice(line: string): ResourceAmount =
    let parts = line.split(" ")
    var (ore, clay, obsidian, geode) = (0, 0, 0, 0)
    var number: int

    for word in parts:
        case word
        of "and": number = 0
        of "ore": ore += number
        of "clay": clay += number
        of "obsidian": obsidian += number
        of "geode": geode += number
        else: number = parseInt(word)

    return (ore, clay, obsidian, geode)

proc parseBlueprint(line: string): Blueprint =
    let halves = line.split(": ")
    let robots = halves[1].split(". ")

    return Blueprint(
        id: parseInt(halves[0][10..^1]),
        robots: [
            parsePrice(robots[0][21..^1]),
            parsePrice(robots[1][22..^1]),
            parsePrice(robots[2][26..^1]),
            parsePrice(robots[3][23..^2]),
        ],
    )

proc parseProblem(input: string): seq[Blueprint] =
    return input.splitLines().map(parseBlueprint)

proc `+`(first: ResourceAmount, second: ResourceAmount): ResourceAmount =
    return (
        first.ore + second.ore,
        first.clay + second.clay,
        first.obsidian + second.obsidian,
        first.geode + second.geode,
    )

proc `-`(first: ResourceAmount, second: ResourceAmount): ResourceAmount =
    return (
        first.ore - second.ore,
        first.clay - second.clay,
        first.obsidian - second.obsidian,
        first.geode - second.geode,
    )

proc canBuild(resources: ResourceAmount, price: ResourceAmount): bool =
    return resources.ore >= price.ore and
       resources.clay >= price.clay and
       resources.obsidian >= price.obsidian and
       resources.geode >= price.geode

proc findMaxNumberOfGeodes(blueprint: Blueprint, minutes: int): int =
    var maxRobotsRequired: array[4, int] = [
        max([blueprint.robots[0].ore,
            blueprint.robots[1].ore,
            blueprint.robots[2].ore,
            blueprint.robots[3].ore]),
        max([blueprint.robots[0].clay,
            blueprint.robots[1].clay,
            blueprint.robots[2].clay,
            blueprint.robots[3].clay]),
        max([blueprint.robots[0].obsidian,
            blueprint.robots[1].obsidian,
            blueprint.robots[2].obsidian,
            blueprint.robots[3].obsidian]),
        int.high(),
    ]

    proc dp(minutesRemaining: int, state: SimulationState): int =
        if minutesRemaining <= 0:
            return state.resources.geode

        var maxGeodes = state.resources.geode

        let newResources = state.resources + state.robots
        let robots = [
            state.robots.ore,
            state.robots.clay,
            state.robots.obsidian,
            state.robots.geode,
        ]

        for idx, robotPrice in blueprint.robots:
            if robots[idx] < maxRobotsRequired[idx] and
               state.resources.canBuild(robotPrice):
                maxGeodes = max(
                    maxGeodes,
                    dp(
                        minutesRemaining-1,
                        (
                            newResources - robotPrice,
                            state.robots + robotIncrease[idx],
                        )
                    )
                )

        maxGeodes = max(
            maxGeodes,
            dp(minutesRemaining-1, (newResources, state.robots))
        )

        return maxGeodes

    return dp(
        minutesRemaining = minutes,
        state = (
            (0, 0, 0, 0),
            (1, 0, 0, 0),
        )
    )

proc part1(blueprints: seq[Blueprint]): int =
    for blueprint in blueprints:
        echo blueprint.id, " ", findMaxNumberOfGeodes(blueprint, 24)
    0
    # return blueprints
    #     .map(b => b.id * findMaxNumberOfGeodes(b, 24))
    #     .foldl(a + b, 0)

proc part2(blueprints: seq[Blueprint]): int =
    0
    # return blueprints[0..2]
    #     .map(b => findMaxNumberOfGeodes(b, 32))
    #     .foldl(a * b, 1)

proc main() =
    var blueprints = parseProblem(readInputFile())
    echo "Part 1: ", part1(blueprints)
    echo "Part 2: ", part2(blueprints)

main()
