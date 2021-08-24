import * as core from '@actions/core'
import * as github from '@actions/github'

import mustache from 'mustache'
import random from 'lodash.random'
import camelCase from 'lodash.camelcase'


async function run() {
  try {
    const context = github.context
    const comment = getComment()
    const payload = context.payload.issue || context.payload.pull_request
    if (comment && payload) {
      const octokit = getOctokit()
      const { data } = await octokit.issues.createComment({
        ...context.repo,
        issue_number: payload.number,
        body: pickComment(comment, {
          author: payload.user.login,
          id: payload.number.toString(),
        }),
      })
    }
  } catch (e) {
    core.error(e)
    core.setFailed(e.message)
  }
}

run()

const eventTypes = {
  issues: [
    'opened',
    'edited',
    'deleted',
    'transferred',
    'pinned',
    'unpinned',
    'closed',
    'reopened',
    'assigned',
    'unassigned',
    'labeled',
    'unlabeled',
    'locked',
    'unlocked',
    'milestoned',
    'demilestoned',
  ],
  pull_request: [
    'assigned',
    'unassigned',
    'labeled',
    'unlabeled',
    'opened',
    'edited',
    'closed',
    'reopened',
    'synchronize',
    'ready_for_review',
    'locked',
    'unlocked',
    'review_requested',
    'review_request_removed',
  ],
}

function getOctokit() {
  const token = core.getInput('GITHUB_TOKEN', { required: true })
  return github.getOctokit(token)
}

function pickComment(
  comment: string | string[],
  args?: { [key: string]: string },
) {
  let result: string
  if (typeof comment === 'string' || comment instanceof String) {
    result = comment.toString()
  } else {
    const pos = random(0, comment.length, false)
    result = comment[pos] || comment[0]
  }

  return args ? mustache.render(result, args) : result
}

function getEventName() {
  const context = github.context
  const eventName = context.eventName
  const event = (eventName === 'pull_request_target'
    ? 'pull_request'
    : eventName) as 'issues' | 'pull_request'
  const action = context.payload.action as string
  const actions = eventTypes[event]
  return actions.includes(action) ? camelCase(`${event}.${action}`) : null
}

function getComment() {
  const eventName = getEventName()
  if (eventName) {
    return core.getInput(eventName) || core.getInput(`${eventName}Comment`)
  }

  return null
}