import * as core from '@actions/core'
import * as github from '@actions/github'
import { Reaction } from './reaction'
import { Util } from './util'

export namespace Action {
  export async function run() {
    try {
      const context = github.context
      const comment = Util.getComment()
      const payload = context.payload.issue || context.payload.pull_request
      if (comment && payload) {
        const octokit = Util.getOctokit()
        const { data } = await octokit.issues.createComment({
          ...context.repo,
          issue_number: payload.number,
          body: Util.pickComment(comment, {
            author: payload.user.login,
            id: payload.number.toString(),
          }),
        })

        octokit.reactions.deleteLegacy()

        const reactions = Util.getReactions()
        if (reactions) {
          await Reaction.add(octokit, data.id, reactions)
        }
      }
    } catch (e) {
      core.error(e)
      core.setFailed(e.message)
    }
  }
}
