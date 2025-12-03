import * as github from '@actions/github';
export declare namespace Reaction {
    function add(octokit: ReturnType<typeof github.getOctokit>, comment_id: number, // tslint:disable-line
    reactions: string | string[], owner?: string, repo?: string): Promise<(import("@octokit/types").OctokitResponse<{
        id: number;
        node_id: string;
        user: {
            name?: string | null | undefined;
            email?: string | null | undefined;
            login: string;
            id: number;
            node_id: string;
            avatar_url: string;
            gravatar_id: string | null;
            url: string;
            html_url: string;
            followers_url: string;
            following_url: string;
            gists_url: string;
            starred_url: string;
            subscriptions_url: string;
            organizations_url: string;
            repos_url: string;
            events_url: string;
            received_events_url: string;
            type: string;
            site_admin: boolean;
            starred_at?: string | undefined;
        } | null;
        content: "+1" | "-1" | "laugh" | "confused" | "heart" | "hooray" | "rocket" | "eyes";
        created_at: string;
    }, 200> | import("@octokit/types").OctokitResponse<{
        id: number;
        node_id: string;
        user: {
            name?: string | null | undefined;
            email?: string | null | undefined;
            login: string;
            id: number;
            node_id: string;
            avatar_url: string;
            gravatar_id: string | null;
            url: string;
            html_url: string;
            followers_url: string;
            following_url: string;
            gists_url: string;
            starred_url: string;
            subscriptions_url: string;
            organizations_url: string;
            repos_url: string;
            events_url: string;
            received_events_url: string;
            type: string;
            site_admin: boolean;
            starred_at?: string | undefined;
        } | null;
        content: "+1" | "-1" | "laugh" | "confused" | "heart" | "hooray" | "rocket" | "eyes";
        created_at: string;
    }, 201> | undefined)[] | undefined>;
}
