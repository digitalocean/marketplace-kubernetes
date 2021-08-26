export declare namespace Util {
    function getOctokit(): {
        [x: string]: any;
    } & {
        [x: string]: any;
    } & import("@octokit/core").Octokit & import("@octokit/plugin-rest-endpoint-methods/dist-types/generated/method-types").RestEndpointMethods & {
        paginate: import("@octokit/plugin-paginate-rest").PaginateInterface;
    };
    function pickComment(comment: string | string[], args?: {
        [key: string]: string;
    }): string;
    function getComment(): string | null;
    function getReactions(): string | null;
}
