# OpenClaw Digital Nomad Skills Smoke Tests

This checklist is for quickly validating that the newly installed OpenClaw skills are usable in realistic digital-nomad scenarios.

## How To Use

Start a fresh OpenClaw session after the gateway restart, then try the prompts below in natural Chinese.

What to look for:

1. Fewer unnecessary clarification questions
2. Better structured answers with practical tradeoffs
3. Reasonable defaults when some parameters are missing
4. Recommendations shaped for digital nomad life, not generic tourism

## 1. City Selection

Prompt:

```text
比较一下曼谷、吉隆坡和岘港，哪个更适合数字游民住一个月。我比较看重成本、网络稳定性和生活方便。
```

Expected behavior:

1. Compare cost, internet, convenience, coworking, and tradeoffs
2. Give a shortlist instead of only generic city descriptions
3. Avoid asking too many questions before giving a first-pass answer

Likely skills:

1. `nomad-city-selector`
2. `intent-amplifier`

## 2. Neighborhood Selection

Prompt:

```text
我准备去东京待两周并远程办公，帮我比较一下涩谷、新宿和中目黑，哪片更适合住。
```

Expected behavior:

1. Compare noise, transit, workability, food access, and convenience
2. Explain which area fits short-stay work best
3. Mention likely tradeoffs instead of pretending one area is perfect

Likely skills:

1. `nomad-neighborhood-scout`
2. `nomad-stay-area-picker`

## 3. Nearby Essentials

Prompt:

```text
我住在曼谷 Ari 一带，帮我找一下附近适合办公的地方，还有超市、药店和洗衣店。
```

Expected behavior:

1. Group by essential category
2. Prioritize work spot plus daily-life basics
3. Be explicit when information is inferred rather than freshly verified

Likely skills:

1. `poi-discovery-guide`
2. `local-essentials-guide`
3. `coworking-finder`

## 4. Workday Planning

Prompt:

```text
我今天下午 3 点到 6 点要开会，人在大阪，帮我安排一个低风险的 remote work 日程。
```

Expected behavior:

1. Suggest main work block and meeting-safe block
2. Include meal and movement windows
3. Include one backup option for Wi-Fi or venue failure

Likely skills:

1. `nomad-workday-planner`
2. `intent-amplifier`

## 5. Itinerary Planning

Prompt:

```text
我下周去曼谷办公三天，顺便玩两天，帮我安排一个不要太折腾、适合数字游民的行程。
```

Expected behavior:

1. Separate work-safe days and exploration windows
2. Avoid overpacking arrival day
3. Keep the schedule practical rather than tourist-heavy

Likely skills:

1. `nomad-trip-orchestrator`
2. `travel-intent-router`

## 6. Budget Control

Prompt:

```text
如果我去清迈 remote work 两周，预算想控制住，帮我做一个大概的成本拆分，并告诉我哪里不能乱省。
```

Expected behavior:

1. Break cost into flights, stay, food, transport, coworking, data
2. Highlight false savings that hurt work reliability
3. Provide practical savings suggestions

Likely skills:

1. `nomad-budget-guard`

## 7. Arrival Checklist

Prompt:

```text
我明天下午到巴厘岛，帮我做一个数字游民落地 24 小时 checklist。
```

Expected behavior:

1. Separate arrival day, first night, and first workday
2. Include internet backup, food fallback, and workspace backup
3. Focus on low-friction setup, not sightseeing

Likely skills:

1. `nomad-landing-checklist`
2. `nomad-admin-checklist`

## 8. Plan Audit

Prompt:

```text
帮我审一下这个计划：晚上红眼航班到东京，第二天上午就开重要会议，住的地方离地铁站 15 分钟步行。
```

Expected behavior:

1. Flag weak points clearly
2. Rank risks by severity
3. Propose mitigations, not just criticism

Likely skills:

1. `nomad-plan-audit`

## 9. Social Discovery

Prompt:

```text
我刚到吉隆坡，想认识一些 remote worker 或创业者，帮我想想从哪里开始比较低门槛。
```

Expected behavior:

1. Recommend easy entry points before high-effort networking
2. Balance social and professional options
3. Avoid giving only generic nightlife advice

Likely skills:

1. `nomad-social-discovery`

## 10. Gear Check

Prompt:

```text
我后天出发去日本远程办公两周，帮我检查一下数字游民装备有没有遗漏。
```

Expected behavior:

1. Separate must-pack and recommended items
2. Include charging, adapters, connectivity, and meeting gear
3. Emphasize redundancy for critical work items

Likely skills:

1. `nomad-gear-check`

## 11. Food Ordering

Prompt:

```text
我今晚想点外卖，预算别太高，最好适合工作日晚饭，不要太油腻。
```

Expected behavior:

1. Infer dinner context and budget sensitivity
2. Present a small number of options
3. Avoid forcing too many optional parameters up front

Likely skills:

1. `Food Delivery`
2. `intent-amplifier`

## 12. Web Research

Prompt:

```text
帮我研究一下清迈 Nimman 区最近是不是还适合数字游民，重点看办公、生活方便度和口碑。
```

Expected behavior:

1. Use multiple-source synthesis rather than one blog summary
2. Separate consensus from uncertainty
3. End with a practical recommendation

Likely skills:

1. `web-research-synthesizer`
2. `poi-discovery-guide`

## Pass Criteria

Consider the setup successful if most prompts show these traits:

1. OpenClaw gives a useful first answer before asking follow-up questions
2. The response reflects digital-nomad priorities instead of generic travel content
3. The system uses practical defaults when safe
4. It identifies risks, tradeoffs, and backups naturally
5. It is explicit about uncertainty for live place data or fast-changing web info