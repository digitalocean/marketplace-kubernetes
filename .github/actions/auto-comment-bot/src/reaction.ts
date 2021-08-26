import * as core from '@actions/core'
import * as github from '@actions/github'

export namespace Reaction {
  const presets = [
    '+1',
    '-1',
    'laugh',
    'confused',
    'heart',
    'hooray',
    'rocket',
    'eyes',
  ] as const

  type ReactionType = typeof presets[number]

  function getReactions(inputs: string | string[]) {
    const candidates = Array.isArray(inputs)
      ? inputs
      : inputs.split(inputs.indexOf(',') >= 0 ? ',' : /\s+/g)

    return candidates
      .map((item) => item.trim())
      .filter((item: ReactionType) => {
        if (item) {
          if (presets.includes(item)) {
            return true
          }
          core.debug(`Skipping invalid reaction '${item}'.`)
          return false
        }
      }) as ReactionType[]
  }

  export async function add(
    octokit: ReturnType<typeof github.getOctokit>,
    comment_id: number, // tslint:disable-line
    reactions: string | string[],
    owner: string = github.context.repo.owner,
    repo: string = github.context.repo.repo,
  ) {
    const candidates = getReactions(reactions)

    if (candidates.length <= 0) {
      core.debug(`No valid reactions are contained in '${reactions}'.`)
      return
    }

    core.debug(`Setting '${candidates.join(', ')}' reaction on comment.`)

    const deferreds = candidates.map((content) => {
      try {
        return octokit.reactions.createForIssueComment({
          owner,
          repo,
          comment_id,
          content,
        })
      } catch (e) {
        core.debug(
          `Adding reaction '${content}' to comment failed with: ${e.message}.`,
        )
        core.error(e)
      }
    })

    return Promise.all(deferreds)
  }
}
