# Harness Delivery Template

每次 Flutter 改动默认按以下结构交付：

## 1. Requirement Frame

- 页面流程或业务目标
- 影响的接口、路由、状态、平台能力
- 正常路径、失败恢复、兼容约束

## 2. Change Plan

- 根因或需求落点
- 最小闭环改动
- 回滚影响面

## 3. Validation

- 已执行的 build、test、关键设备或模拟器场景
- 未验证平台、机型或支付登录路径

## 4. Observability

- 关键日志、状态追踪点、用户反馈
- 出问题时如何快速定位

## 5. Delivery Summary

- 已实现
- 已验证
- 剩余风险
- 下一步建议
