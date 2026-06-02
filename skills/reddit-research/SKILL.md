---
name: reddit-research
description: >-
  Comprehensive Reddit research without failing. Routes through Arctic Shift API,
  curl JSON endpoints, Playwright, and web search for subreddit analysis, engagement
  metrics, user activity, deleted/removed post recovery, tone assessment, rules,
  shadowban detection, and topic discovery.
license: MIT
metadata:
  version: 1.0.0
  dependencies:
    - url: https://arctic-shift.photon-reddit.com/api
      name: Arctic Shift API
      type: api
    - url: https://www.reddit.com
      name: Reddit JSON API
      type: api
---

# Reddit Research Skill

Comprehensive Reddit research routing through the most reliable methods. You know exactly which tools work, which don't, and when to use each.

## Trigger

```
/reddit-research analyze r/homelab engagement
/reddit-research what subs does u/example_user post in
/reddit-research find deleted posts in r/SUBNAME
/reddit-research discover subreddits about topic X
search reddit for discussions about X
check reddit metrics for these subreddits
```

---

## Method Ranking (Most to Least Efficient)

### Tier 1: Arctic Shift API via WebFetch (PRIMARY)

**Always works. No auth. No rate limits. Richest data.**

- URL: `https://arctic-shift.photon-reddit.com/api`
- Access: WebFetch tool or HTTP GET (any client)
- Works from: Any IP, any network, always
- Unique advantage: **Sees deleted, removed, and spam-filtered posts** that ALL other methods miss

Use for: All historical research, metrics, user activity, rules, tone analysis, deleted content recovery.

### Tier 2: curl to Reddit JSON API

**Live data. 100 requests per ~2 minute window.**

- URL: `https://www.reddit.com/{endpoint}.json`
- Access: curl or any HTTP client
- Rate limit: 100 req / ~2 min (check `x-ratelimit-remaining` header)
- REQUIRES User-Agent in Reddit script format: `platform:appname:version (by /u/username)`

Use for: Live hot/new/top/rising rankings, current subscriber counts, real-time search, threaded comments, subreddit discovery.

### Fallback: Playwright Browser Automation (ONLY if Tier 1+2 fail)

**Do NOT use Playwright unless Arctic Shift and curl have both failed or cannot fulfill the specific need.**

- Use `old.reddit.com` URLs (simpler DOM)
- Bypasses all blocks (real Chrome session)
- CANNOT see deleted/removed posts
- SLOW: browser startup + page render + large snapshots

Use ONLY when: curl is returning 429 (exhausted rate limit), you need a logged-in session, or you need visual page inspection. Never use as a first choice.

### Tier 4: Web Search (discovery)

**Good for broad discovery. Returns snippets, not full content.**

- Use any available web search tool with `site:reddit.com` filter
- Works for: Finding relevant threads when you don't know which subreddit to look in
- Limitation: Returns summaries/snippets, not full post data

---

## Methods That DO NOT Work (Never Attempt)

| Method | Why | Error |
|--------|-----|-------|
| WebFetch to reddit.com | Many tools block reddit.com | "unable to fetch" |
| Reddit RSS (.rss feeds) via curl | Reddit blocks RSS specifically | 403 Forbidden |
| oauth.reddit.com without token | Redirects to HTML page | 301 -> HTML |

---

## Arctic Shift API Reference

**Base URL:** `https://arctic-shift.photon-reddit.com/api`

### Endpoints

| Endpoint | Use Case |
|----------|----------|
| `/api/posts/search?subreddit=X&limit=100&sort=desc` | Posts in a subreddit |
| `/api/comments/search?subreddit=X&limit=100&sort=desc` | Comments in a subreddit |
| `/api/users/interactions/subreddits?author=X&limit=50` | All subs a user participates in |
| `/api/subreddits/rules?subreddits=sub1,sub2,sub3` | Bulk rules (up to 1000 subs) |
| `/api/subreddits/search?subreddit_prefix=X` | Subreddit metadata/discovery |
| `/api/posts/search?author=X&subreddit=Y&limit=50&sort=desc` | Posts by specific author |
| `/api/posts/search?subreddit=X&after=UNIX&before=UNIX&limit=100&sort=desc` | Date-filtered |

### Gotchas

- `sort` accepts ONLY `asc` or `desc` (date order). No sort-by-score. Fetch then sort client-side.
- Posts < ~36 hours old: `hide_score: true`, `score: 1`. ALWAYS filter before computing metrics.
- `view_count` is always null. Reddit never exposes this externally.
- Subscriber count is archive-time. Use curl `/about.json` for live count.
- Deleted posts: Only captured if Arctic Shift crawled before deletion.

### Key Response Fields (Posts)

```json
{
  "score": 847,
  "num_comments": 42,
  "upvote_ratio": 0.97,
  "title": "...",
  "link_flair_text": "Discussion",
  "author": "username",
  "created_utc": 1715000000,
  "subreddit_subscribers": 124000,
  "over_18": true,
  "selftext": "...",
  "permalink": "/r/SUBNAME/comments/...",
  "hide_score": false
}
```

---

## Reddit JSON API Reference (curl)

**User-Agent (REQUIRED):** `platform:your-app-name:v1.0 (by /u/your_username)`

**Rate limit:** 100 requests per ~2 minutes. Check headers:
```
x-ratelimit-remaining: 81.0
x-ratelimit-reset: 103
```

### Endpoints

| Endpoint | Returns |
|----------|---------|
| `/r/{sub}/hot.json?limit=25` | Hot posts (current ranking) |
| `/r/{sub}/new.json?limit=25` | Newest posts |
| `/r/{sub}/top.json?t=week&limit=25` | Top posts (t=hour,day,week,month,year,all) |
| `/r/{sub}/rising.json?limit=25` | Rising posts |
| `/r/{sub}/about.json` | Sub metadata (live subscriber count, description) |
| `/r/{sub}/comments/{post_id}.json` | Full threaded comments for a post |
| `/search.json?q=QUERY&sort=relevance&limit=25` | Cross-sub search |
| `/subreddits/search.json?q=QUERY&limit=25` | Discover subreddits |
| `/user/{name}/about.json` | User profile (200=exists, 404=shadowbanned) |

### curl Template

```bash
curl -s "https://www.reddit.com/r/SUBNAME/hot.json?limit=25" \
  -H "User-Agent: platform:your-app-name:v1.0 (by /u/your_username)"
```

---

## Data Richness Comparison

| Content Type | Arctic Shift | curl (live reddit) | Playwright |
|-------------|:---:|:---:|:---:|
| Normal posts | Yes | Yes | Yes |
| Author-deleted posts | **Yes** | No ([deleted]) | No |
| Mod-removed posts | **Yes** | No ([removed]) | No |
| Spam-filtered posts | **Yes** | No (invisible) | No |
| Live hot/new/top ranking | No | **Yes** | Yes |
| Real-time subscriber count | No | **Yes** | Yes |
| Threaded comments | Flat only | **Full tree** | Full tree |
| Cross-sub search | By sub only | **Yes** | Yes |
| Subreddit discovery by topic | Prefix only | **Yes** | Yes |
| Historical archive (months+) | **Yes** | Limited | Limited |

**Bottom line:** Arctic Shift for depth and deleted content. curl for live rankings, search, and discovery. They complement each other.

---

## Engagement Metrics

### The Four Metrics (compute from Arctic Shift data)

| Metric | Formula | Measures |
|--------|---------|----------|
| Comments/upvotes ratio (cmtRatio) | `avgCmts / avgScore` | Discussion depth |
| Upvote ratio | `upvote_ratio` field (0-1) | Community approval |
| Avg comments per post | `sum(num_comments) / count` | Activity level |
| Avg score per post | `sum(score) / count` | Reach/visibility |

### Computation

```javascript
const posts = data.data.filter(p => !p.hide_score && p.score > 1);
const avgScore = posts.reduce((s, p) => s + p.score, 0) / posts.length;
const avgCmts = posts.reduce((s, p) => s + p.num_comments, 0) / posts.length;
const cmtRatio = avgCmts / avgScore;
const avgUpvoteRatio = posts.reduce((s, p) => s + p.upvote_ratio, 0) / posts.length;
```

### Discussion-Depth Tiers

| Tier | Threshold | Meaning |
|------|-----------|---------|
| S | >= 0.70 | Highly conversational |
| A | >= 0.25 | Strong discussion |
| B | >= 0.10 or avg cmts >= 10 | Moderate, worth engaging |
| C | 0.05-0.10 | Mostly passive / reach sub |
| D | < 0.05 | Low engagement |
| E | avg cmts < 1 | Dead or hard-gated |

---

## Tone Assessment

Assess from post data already fetched (no extra calls):

1. `link_flair_text` values - themed days, categories, explicit indicators
2. Title patterns - language style, norms
3. `selftext` on top-scoring posts - culture signals
4. Score distribution - what the community actually rewards

Sort fetched posts by score client-side. Top 10-20 reveal community values.

---

## Standard Workflows

### Research a Subreddit (2-3 calls)

```
# Arctic Shift: rules + historical metrics
WebFetch: .../api/subreddits/rules?subreddits=SUBNAME
WebFetch: .../api/posts/search?subreddit=SUBNAME&limit=100&sort=desc

# curl: live subscriber count + current hot
curl: https://www.reddit.com/r/SUBNAME/about.json (subscribers)
```

### Investigate a User

```
# Arctic Shift: where they participate
WebFetch: .../api/users/interactions/subreddits?author=USERNAME&limit=50

# Then research promising subs
```

### Find Reddit Threads About a Topic

```
# curl: cross-sub search (live, ranked by relevance)
curl: https://www.reddit.com/search.json?q=TOPIC&sort=relevance&limit=25

# Web search: broader web-indexed results
search "site:reddit.com TOPIC"
```

### Discover Subreddits

```
# curl: Reddit's subreddit search
curl: https://www.reddit.com/subreddits/search.json?q=TOPIC&limit=25

# Arctic Shift: prefix-based
WebFetch: .../api/subreddits/search?subreddit_prefix=PREFIX
```

### Batch-Check Multiple Subs

```
# Arctic Shift: rules in one call (up to 1000)
WebFetch: .../api/subreddits/rules?subreddits=sub1,sub2,sub3

# Arctic Shift: posts per sub (parallel via sub-agents)
WebFetch: .../api/posts/search?subreddit=sub1&limit=50&sort=desc
WebFetch: .../api/posts/search?subreddit=sub2&limit=50&sort=desc
```

### Recover Deleted/Removed Posts

```
# ONLY Arctic Shift can do this
WebFetch: .../api/posts/search?subreddit=SUBNAME&limit=100&sort=desc
# Posts where live Reddit shows [deleted]/[removed] still have full content here
```

### Shadowban Detection

```
# Use curl (fast, no browser needed)
curl -s -o /dev/null -w "%{http_code}" "https://www.reddit.com/user/USERNAME/about.json" \
  -H "User-Agent: platform:your-app-name:v1.0 (by /u/your_username)"
# 200 = alive, 404 = shadowbanned

# If curl fails (429), THEN fall back to Playwright:
# Navigate to https://www.reddit.com/user/USERNAME
# Check if page title contains username or shows "page not found"
```

---

## Decision Flowchart

```
Need Reddit data?
|
+-- Historical posts, metrics, user activity, deleted content?
|     --> Arctic Shift (WebFetch) - always works, richest data
|
+-- Live rankings (hot/new/top/rising)?
|     --> curl to reddit.com .json endpoints
|
+-- Live subscriber count or sub metadata?
|     --> curl to /r/SUBNAME/about.json
|
+-- Cross-sub topic search ("find threads about X")?
|     --> curl to /search.json OR web search
|
+-- Discover subreddits by keyword?
|     --> curl to /subreddits/search.json
|
+-- Full threaded comments on a post?
|     --> curl to /r/SUB/comments/ID.json
|
+-- Shadowban check?
|     --> curl to /user/NAME/about.json (200=alive, 404=banned)
|
+-- Arctic Shift AND curl both failing?
|     --> ONLY THEN use Playwright (old.reddit.com, last resort)
|
+-- Posting, commenting, DMs, modmail?
      --> NOT possible via research tools. Use Reddit's own interface.
```

**Playwright is a last resort.** Only reach for it when Arctic Shift returns errors AND curl is rate-limited (429) or failing. Never use Playwright as a first or second choice for data that Arctic Shift or curl can provide.

---

## Scope Boundaries

- This skill is READ-ONLY research. No posting, commenting, or write operations.
- If the task requires posting or account actions, inform the user it must be done through Reddit's interface or an authenticated client.
