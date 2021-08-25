> Github action to comment issues or PRs on events triggered.

## Usage

Create a `.github/workflows/auto-comment.yml` file in the repository you want to install this action, then add the following to it:

```yml
name: Auto Comment
on: [issues, pull_request]
jobs:
  run:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v2
      - name: Use local Auto Comment Bot
        uses: ./.github/actions/auto-comment-bot
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          issuesOpened: >
            👋 @{{ author }}
            
            Thank you for raising an issue. We will will investigate into the matter and get back to you as soon as possible.
            
            Please make sure you have given us as much context as possible.


          pullRequestOpened: >
            👋 @{{ author }}
            
            Thank you for raising your pull request.
            
            Please make sure you have followed our contributing guidelines. We will review it as soon as possible
```

There are a couple of events that you will need to setup depending on what you want.

### Available Events

- issuesOpened
- issuesEdited
- issuesDeleted
- issuesTransferred
- issuesPinned
- issuesUnpinned
- issuesClosed
- issuesReopened
- issuesAssigned
- issuesUnassigned
- issuesLabeled
- issuesUnlabeled
- issuesLocked
- issuesUnlocked
- issuesMilestoned
- issuesDemilestoned

- pullRequestAssigned
- pullRequestUnassigned
- pullRequestLabeled
- pullRequestUnlabeled
- pullRequestEdited
- pullRequestOpened
- pullRequestClosed
- pullRequestReopened
- pullRequestSynchronize
- pullRequestReadyForReview
- pullRequestLocked
- pullRequestUnlocked
- pullRequestReviewRequested
- pullRequestReviewRequestRemoved

And we can also add reactions to comment with `[eventName]Comment` and `[eventName]Reactions` input. Available reactions:

- `+1` 👍
- `-1` 👎
- `laugh` 😄
- `confused` 😕
- `heart` ❤️
- `hooray` 🎉
- `rocket` 🚀
- `eyes` 👀

```yml
name: Auto Comment
on: [issues, pull_request]
jobs:
  run:
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@v2
      - name: Use local Auto Comment Bot
        uses: ./.github/actions/auto-comment-bot
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          issuesOpenedReactions: 'hooray, +1'
          issuesOpenedComment: >
            👋 @{{ author }}
            
            Thank you for raising an issue. We will investigate into the matter and get back to you as soon as possible.
            
            Please make sure you have given us as much context as possible.
```

### Available Variables

| Name | Description |
| --- | --- |
| {{author}} | The GitHub username of the person who opened the issue / pull request |
| {{id}} | The numeric id of the issue / pull request |

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE)
