# [M0] 编译、签名并安装至真实 iPad

**Goal:** 把当前 XcodeGen 工程在 Mac 上成功构建、安装并打开。

**Acceptance:**
- [ ] `./scripts/bootstrap.sh` 生成项目成功。
- [ ] `./scripts/check.sh` Simulator 编译成功。
- [ ] Xcode 登录 Personal Team、调整唯一 bundle ID，真机安装并启动。
- [ ] 在 `docs/TEST_PLAN.md` 记录 Mac/Xcode/iPadOS 版本和具体执行结果。
- [ ] 同步 `PROGRESS.md` 和 `handoff.md`。

**Not in scope:** PDF、同步、文件夹。不要把能编译称为功能验收通过。
