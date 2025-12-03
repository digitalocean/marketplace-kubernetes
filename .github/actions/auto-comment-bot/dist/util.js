"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Util = void 0;
var core = __importStar(require("@actions/core"));
var github = __importStar(require("@actions/github"));
var mustache_1 = __importDefault(require("mustache"));
var lodash_random_1 = __importDefault(require("lodash.random"));
var lodash_camelcase_1 = __importDefault(require("lodash.camelcase"));
var Util;
(function (Util) {
    function getOctokit() {
        var token = core.getInput('GITHUB_TOKEN', { required: true });
        return github.getOctokit(token);
    }
    Util.getOctokit = getOctokit;
    function pickComment(comment, args) {
        var result;
        if (typeof comment === 'string' || comment instanceof String) {
            result = comment.toString();
        }
        else {
            var pos = (0, lodash_random_1.default)(0, comment.length, false);
            result = comment[pos] || comment[0];
        }
        return args ? mustache_1.default.render(result, args) : result;
    }
    Util.pickComment = pickComment;
    var eventTypes = {
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
    };
    function getEventName() {
        var context = github.context;
        var eventName = context.eventName;
        var event = (eventName === 'pull_request_target'
            ? 'pull_request'
            : eventName);
        var action = context.payload.action;
        var actions = eventTypes[event];
        return actions.includes(action) ? (0, lodash_camelcase_1.default)("".concat(event, ".").concat(action)) : null;
    }
    function getComment() {
        var eventName = getEventName();
        if (eventName) {
            return core.getInput(eventName) || core.getInput("".concat(eventName, "Comment"));
        }
        return null;
    }
    Util.getComment = getComment;
    function getReactions() {
        var eventName = getEventName();
        if (eventName) {
            return core.getInput("".concat(eventName, "Reactions"));
        }
        return null;
    }
    Util.getReactions = getReactions;
})(Util = exports.Util || (exports.Util = {}));
//# sourceMappingURL=util.js.map