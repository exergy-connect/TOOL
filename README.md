# T👀L - Truly Open Online Learning resources
The [T👀L environment](https://openimitation.org) is a loosely organized set of resources to encourage the creation and sharing of online learning skills and solutions.

## Context and history
I've been having some interesting back-and-forth discussions with [Ivan Pepelnjak](https://www.linkedin.com/in/ivanpepelnjak/), networking expert and author of [IPSpace.net](https://blog.ipspace.net/). To summarize, Ivan teaches networking and ended up [creating a lab scenario on Katacoda](https://blog.ipspace.net/2021/04/katacoda-netsim-containerlab-frr.html)

[Katacoda.com](https://katacoda.com/ipspace/scenarios/netsim-containerlab-101) is created by O'Reilly, and offers free tier access to GitHub-based learning scenarios of all shapes and sizes. In a familiar, easy-to-use web browser environment students get to practice configuration exercises in the cloud. So that's wonderful, kudos to them for providing this learning-as-a-service platform. However, there are some limitations:
* The platform requires (free) registration, which represents a blocking issue for several people I spoke with
* The platform provides limited central resources, commodity cloud servers that are easy to get in general, but hard to customize in the Katacoda environment
* For students, the lab exercises are read-only - there is no built-in feedback mechanism

As Ivan pointed out, the key issue here isn't the tooling - tools are easily found, and instructions only a Google search away. The problem is getting **quality, updated and well maintained relevant content**.

## High quality maintained content at scale
With software, the only constant is change. Things evolve rapidly as millions of developers push the envelope of the possible, and consequently the carefully tested instructions we write today may well break tomorrow. Even in a relatively simple first example, Ivan already reported issues with specific FRR versions (had to use 7.5.0) and [several new image versions](https://hub.docker.com/r/frrouting/frr/tags?page=1&ordering=last_updated) were posted since the April 27 release, just one month ago.

Who would detect such issues? Probably not Ivan - he has better things to do than going through previous lab exercises, making sure they still work. More likely it would be a student, someone trying to follow the instructions at some future point in time. They might try to reach out, or give up, but there is no obvious feedback channel.

There is clearly a need for a better, more maintainable model here. And there is an obvious one: Use GitHub directly

# GitHub-centric e-learning💡
With content provided as GitHub repos, students could start by cloning the repo under their own account. This helps to keep track of all the courses and material that were explored, and allows for students to add comments or corrections. The originating repo owner would get a sense of how popular and relevant their content is, providing guidance for future efforts. Moreover, students could make minor corrections or extend the material and send Pull Requests (PR) to the original author, to show their appreciation and give back. And by doing so, they would learn important digital skills of collaboration in a community, as active participants in the Digital Economy.

What could this look like? Well...
1. Follow the [Setup instructions](https://github.com/exergy-connect/TOOL/wiki/Setup)
2. Open the [sample](https://github.com/exergy-connect/TOOL/blob/main/TrulyOpenOnlineLearning-101.md) and follow instructions

