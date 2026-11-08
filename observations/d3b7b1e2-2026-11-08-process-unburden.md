# 流程减负 skill 初版

目标：把“重新追问流程为什么存在、agent 时代能否砍掉环节”保存为可复用分析方法。

发现：worth 判断候选工作值不值得做，pain-driven-refactoring 面向技术痛点；流程目的、历史条件及整条交接链的必要性需要独立分析入口。选择 flow-skills 承载，npc_8090 的业务目标与代码未变。

实现：新增 process-unburden，追问到可检验结果、外部约束或证据缺口即停；比较总负担，支持删、合并、替代、按需、保留和证据不足，附最小验证方案。

核验：默认 python3 执行 quick_validate.py 缺少 yaml 模块；改用已有 PyYAML 的 /opt/homebrew/opt/python@3.14/bin/python3.14 后校验通过，git diff --check 通过。静态审查确认无效交接可建议取消、真实约束可保留手段或结果、缺乏证据可转小范围实验；这不是独立 agent 行为实测。

后续：真实案例使用时再评估是否确实减轻判断负担；本次未积累足够证据提炼 pattern。
