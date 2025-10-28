# 常用脚本

> 参考资料：[ACT日志综合指南](https://bbs.tggfl.com/topic/8/act%E6%97%A5%E5%BF%97%E7%BB%BC%E5%90%88%E6%8C%87%E5%8D%97)

## 初始化

1. 初始化
    + 对应日志

    ```plain
    [00:00:25.545] 260 104:1:1
    ```

    + 导出脚本

    ```xml
    <?xml version="1.0"?>
    <TriggernometryExport Version="1">
    <ExportedTrigger Enabled="true" Name="1. 初始化" Id="690a41f5-0ef9-41b0-b06d-b099b7276d04"
        RegularExpression="^.{15}\S+ 104:1:1">
        <Actions>
        <Action OrderNumber="1" VariableOp="UnsetRegex" VariableName="^p9s_" ActionType="Variable">
            <Condition Enabled="false" Grouping="And" />
        </Action>
        </Actions>
        <Condition Enabled="false" Grouping="Or" />
    </ExportedTrigger>
    </TriggernometryExport>
    ```

    + 正则说明：匹配字符串```^.{15}\S+ 104:1:1```
    + Action说明：
        1. 清除所有匹配正则表达式```^p9s_```的变量

2. 获取点名（麻将）
    + 对应日志

    ```plain
    [20:34:27.057] TargetIcon 1B:10255B40:player name1:0000:0000:00B5:0000:0000:0000
    [20:34:27.057] TargetIcon 1B:10052B1C:player name2:0000:0000:00B8:0000:0000:0000
    [20:34:27.057] TargetIcon 1B:102A898E:player name3:0000:0000:00BA:0000:0000:0000
    [20:34:27.057] TargetIcon 1B:102D2B64:player name4:0000:0000:00BC:0000:0000:0000
    [20:34:27.057] TargetIcon 1B:40038FD9:player name5:0000:0000:00B6:0000:0000:0000
    [20:34:27.057] TargetIcon 1B:40038FD8:player name6:0000:0000:00B7:0000:0000:0000
    [20:34:27.057] TargetIcon 1B:40038FDB:player name7:0000:0000:00B9:0000:0000:0000
    [20:34:27.057] TargetIcon 1B:40038FDA:player name8:0000:0000:00BB:0000:0000:0000
    ```

    + 导出脚本

    ```xml
    <?xml version="1.0"?>
    <TriggernometryExport Version="1">
    <ExportedTrigger Enabled="true" Name="2. 获取点名" Id="3f5768d3-c39b-4b74-a86a-489d8c04f4e9"
        RegularExpression="^.{15}\S+ 1B:(?&lt;target_id&gt;.{8}):(?&lt;player_name&gt;[^:]*):.{9}:(?&lt;type&gt;.{4}):">
        <Actions>
        <Action OrderNumber="1" VariableOp="SetNumeric" VariableName="p9s_1b_first"
            VariableExpression="hex2dec(${type})" ActionType="Variable" Asynchronous="False">
            <Condition Enabled="true" Grouping="Or">
            <ConditionSingle Enabled="true" ExpressionL="${evar:p9s_1b_first}"
                ExpressionTypeL="Numeric" ExpressionR="0" ExpressionTypeR="Numeric"
                ConditionType="NumericEqual" />
            </Condition>
        </Action>
        <Action OrderNumber="2"
            LogMessageText="p9s_1b:${target_id}:${player_name}:${numeric:hex2dec(${type}) - ${var:p9s_1b_first}}"
            LogProcess="True" ActionType="LogMessage" Asynchronous="False">
            <Condition Enabled="false" Grouping="Or" />
        </Action>
        </Actions>
        <Condition Enabled="false" Grouping="Or" />
    </ExportedTrigger>
    </TriggernometryExport>
    ```

    + 正则说明：匹配字符串```^.{15}\S+ 1B:(?<target_id>.{8}):(?<player_name>[^:]*):.{9}:(?<type>.{4}):```，捕获目标id```target_id```，玩家名称```player_name```，类型```type```。
    + Action说明：
        1. 若```p9s_1b_first```变量未初始化，则初始化为第一次遇到的```type```，目前看一场战斗中麻将的type基准值都是一样的。
        2. 新生成日志```p9s_1b:${target_id}:${player_name}:${numeric:hex2dec(${type}) - ${var:p9s_1b_first}}```交由后续触发器匹配。
    + 新生成的log内容如下：

        ```plain
        p9s_1b:10255B40:player name1:0
        p9s_1b:10052B1C:player name2:3
        p9s_1b:102A898E:player name3:5
        p9s_1b:102D2B64:player name4:7
        p9s_1b:40038FD9:player name5:1
        p9s_1b:40038FD8:player name6:2
        p9s_1b:40038FDB:player name7:4
        p9s_1b:40038FDA:player name8:6
        ```

        最后的数字0-7即代表麻将序号1-8。

## 常用类型

1. 普通技能施放播报
    + 对应日志：

    ```plain
    [20:30:50.722] StartsCasting 14:40038962:Kokytos:814C:Gluttony's Augur:40038962:Kokytos:4.700:99.99:102.56:0.00:3.12
    ```

    + 导出脚本

    ```xml
    <?xml version="1.0"?>
    <TriggernometryExport Version="1">
    <ExportedTrigger Enabled="true" Name="AoE Gluttony's Augur"
        Id="5df3ca51-4aa5-4ddd-8128-a106ebb445b5" RegularExpression="^.{15}\S+ 14:4.{7}:[^:]*:814C:">
        <Actions>
        <Action OrderNumber="1" UseTTSTextExpression="AoE" ActionType="UseTTS" Asynchronous="False">
            <Condition Enabled="false" Grouping="Or" />
        </Action>
        </Actions>
        <Condition Enabled="false" Grouping="Or" />
    </ExportedTrigger>
    </TriggernometryExport>
    ```

2. 麻将播报

    + 对应日志(部分由获取点名（麻将）生成)

        ```plain
        [20:34:20.951] StartsCasting 14:40038962:Kokytos:817C:Levinstrike Summoning:40038962:Kokytos:3.700:99.99:99.99:0.00:3.14
        p9s_1b:10255B40:player name1:0
        p9s_1b:10052B1C:player name2:3
        p9s_1b:102A898E:player name3:5
        p9s_1b:102D2B64:player name4:7
        p9s_1b:40038FD9:player name5:1
        p9s_1b:40038FD8:player name6:2
        p9s_1b:40038FDB:player name7:4
        p9s_1b:40038FDA:player name8:6
        ```

    + 导出脚本

        ```xml
        <?xml version="1.0"?>
        <TriggernometryExport Version="1">
        <ExportedFolder Id="e3475d98-34a9-4a7e-a550-6852b4b5263f" Name="麻将" Enabled="true">
            <Folders />
            <Triggers>
            <Trigger Enabled="true" Name="0. 开始" Id="bff60fc0-afe1-4e4a-becf-977f56629a58" RegularExpression="^.{15}\S+ 14:4.{7}:[^:]*:817C:">
                <Actions>
                <Action OrderNumber="1" VariableOp="SetString" VariableName="p9s_phase_mark" VariableExpression="817C" ActionType="Variable" Asynchronous="False">
                    <Condition Enabled="false" Grouping="Or" />
                </Action>
                </Actions>
                <Condition Enabled="false" Grouping="Or" />
                <Conditions />
            </Trigger>
            <Trigger Enabled="true" Name="1. 麻将点名 1" Id="ce2e6a6b-e3e8-48f1-ad30-1951907f5b12" RegularExpression="^p9s_1b:.{8}:(?&lt;player_name&gt;[^:]+):(?&lt;type&gt;0)$">
                <Actions>
                <Action OrderNumber="1" UseTTSTextExpression="${numeric:${type}+1}号${numeric:${type}+1}号" ActionType="UseTTS" Asynchronous="False">
                    <Condition Enabled="false" Grouping="Or" />
                </Action>
                </Actions>
                <Condition Enabled="true" Grouping="And">
                <ConditionSingle Enabled="true" ExpressionL="${player_name}" ExpressionTypeL="String" ExpressionR="${_ffxivplayer}" ExpressionTypeR="String" ConditionType="StringEqualNocase" />
                <ConditionSingle Enabled="true" ExpressionL="${var:p9s_phase_mark}" ExpressionTypeL="String" ExpressionR="817C" ExpressionTypeR="String" ConditionType="StringEqualNocase" />
                </Condition>
                <Conditions />
            </Trigger>
            <Trigger Enabled="true" Name="1. 麻将点名 2" Id="f6ce19bf-c442-4406-af63-405194f4b1b4" RegularExpression="^p9s_1b:.{8}:(?&lt;player_name&gt;[^:]+):(?&lt;type&gt;1)$">
                <Actions>
                <Action OrderNumber="1" UseTTSTextExpression="${numeric:${type}+1}号${numeric:${type}+1}号" ActionType="UseTTS" Asynchronous="False">
                    <Condition Enabled="false" Grouping="Or" />
                </Action>
                </Actions>
                <Condition Enabled="true" Grouping="And">
                <ConditionSingle Enabled="true" ExpressionL="${player_name}" ExpressionTypeL="String" ExpressionR="${_ffxivplayer}" ExpressionTypeR="String" ConditionType="StringEqualNocase" />
                <ConditionSingle Enabled="true" ExpressionL="${var:p9s_phase_mark}" ExpressionTypeL="String" ExpressionR="817C" ExpressionTypeR="String" ConditionType="StringEqualNocase" />
                </Condition>
                <Conditions />
            </Trigger>
            <Trigger Enabled="true" Name="1. 麻将点名 3" Id="79811a42-6c07-48f9-ace2-becba80645d7" RegularExpression="^p9s_1b:.{8}:(?&lt;player_name&gt;[^:]+):(?&lt;type&gt;2)$">
                <Actions>
                <Action OrderNumber="1" UseTTSTextExpression="${numeric:${type}+1}号${numeric:${type}+1}号" ActionType="UseTTS" Asynchronous="False">
                    <Condition Enabled="false" Grouping="Or" />
                </Action>
                </Actions>
                <Condition Enabled="true" Grouping="And">
                <ConditionSingle Enabled="true" ExpressionL="${player_name}" ExpressionTypeL="String" ExpressionR="${_ffxivplayer}" ExpressionTypeR="String" ConditionType="StringEqualNocase" />
                <ConditionSingle Enabled="true" ExpressionL="${var:p9s_phase_mark}" ExpressionTypeL="String" ExpressionR="817C" ExpressionTypeR="String" ConditionType="StringEqualNocase" />
                </Condition>
                <Conditions />
            </Trigger>
            </Triggers>
        </ExportedFolder>
        </TriggernometryExport>
        ```

    + 注意：使用```p9s_phase_mark```变量确认处于那个机制内。
