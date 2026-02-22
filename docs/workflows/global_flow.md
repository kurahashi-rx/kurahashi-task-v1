# 全体業務フロー (Global Flow)

## 1. 概要
このドキュメントでは、「倉橋タスク」における1日の標準的な業務サイクル（アジャイル開発手法ベース）を定義します。
システムは大きく「デイリースクラム（計画）」「スプリント実行」「振り返り」の3フェーズで構成され、AIコーチによるフィードバックループを回すことを目的としています。

## 2. システム俯瞰図（業務サイクル）
ユーザーが1日を通してシステムとどのように関わるか、全体像を可視化します。

```mermaid
graph TD
    %% ==========================================
    %% 1. ノード（変数）の定義
    %% ==========================================
    Start((1日の始まり))
    End((1日の終わり))

    %% デイリースクラム
    Backlog[バックログメンテ]
    Plan[デイリープランニング]

    %% スプリント実行
    Run[タスク実行]
    Update[完了消し込み / 計画変更]

    %% 振り返り
    Retro[ベロシティ・予実評価]
    AI([AIコーチへの相談])
    Try[Try/改善アクション設定]
    Idea[学びを記録]

    %% ==========================================
    %% 2. フロー（ロジック）の定義
    %% ==========================================
    Start --> Backlog
    
    subgraph G1 [1_デイリースクラム]
        Backlog --> Plan
    end

    Plan -- 仕事開始 --> Run

    subgraph G2 [2_スプリント実行]
        Run --> Update
        Update -. 繰り返し .-> Run
    end

    Update -- 締め--> Retro

    subgraph G3 [3_振り返り]
        Retro --> AI
        AI --> Try
        AI --> Idea
        Idea --> Try
    end

    Try -- 締め--> End

    %% ==========================================
    %% 詳細ドキュメントへのリンク（VS Code等でクリック可能）
    %% ==========================================
    click Backlog "./daily_scrum_scenario.md"
    click Run "./sprint_exec_scenario.md"
    click Retro "./retrospective_scenario.md"

```

## 3. 主要ユーザージャーニーとデータのやり取り

各フェーズの具体的なアクションと、発生するデータのやり取り（I/O）です。

| フェーズ | アクション | 主な操作対象データ (I/O) | 詳細ドキュメント |
| --- | --- | --- | --- |
| **デイリースクラム** | バックログの整理、本日の目標Pt設定、タスク選択と段取り作成 | `Backlog`, `DailyPlan`, `Task` | [計画シナリオ詳細](https://www.google.com/search?q=./daily_scrum_scenario.md) |
| **スプリント実行** | 実際のタスク消化、完了ステータスの更新、必要に応じた計画変更 | `Task` (status), `DailyPlan` | [実行シナリオ詳細](https://www.google.com/search?q=./sprint_exec_scenario.md) |
| **振り返り** | 予実の比較、AIへのフィードバック依頼、翌日以降のTry設定 | `Velocity`, `AIPrompt`, `ActionItem` | [振り返りシナリオ詳細](https://www.google.com/search?q=./retrospective_scenario.md) |

## 4. 共通のルール・制約

* **ポイント(Pt)管理**: タスクの重み付けは時間ではなくPtで行い、キャパシティ（ベロシティ）で1日の業務量をコントロールする。
* **AI連携**: 振り返りフェーズにおいて、外部のAI API（またはAIツール）を利用して客観的な評価を得る仕組みを持つ。

## 5. 関連リンク

* [コンセプト/背景](https://www.google.com/search?q=../concept.md)
* [データモデル (ER図)](https://www.google.com/search?q=../data_model.md)

