# シナリオ詳細：デイリースクラム

## 1. 目的

「今日一日の成果」を最大化するために、現状のバックログを整理し、自身のキャパシティに基づいた現実的な計画を策定する。

## 2. 詳細シーケンス図
システム（App）内でのデータの動きと、ユーザーの思考プロセスの流れを定義します。

```mermaid
sequenceDiagram
    autonumber
    actor User as ユーザー
    participant Task as タスク画面
    participant Sprint as スプリントプランニング画面
    participant DB as データベース

    Note over User, DB: 1. バックログメンテ
        User->>Task: タスク全量の表示
        Task->>DB: SELECT * FROM tasks WHERE status = 'backlog'
        DB-->>Task: タスクデータ
        Task-->>User: バックログ一覧表示
        User->>Task: タスク追加 (Title, Value, Priority, SP)
        Task->>DB: INSERT INTO tasks
        Note right of Task: SP: story_point (1, 3, 5)
        DB-->>Task: Success

    Note over User, DB: 2. デイリープランニング (目標設定)
        User->>Sprint: プランニング画面表示
        Sprint->>DB: SELECT * FROM daily_reports WHERE report_on = TODAY
        DB-->>Sprint: 本日のレポート(存在すれば)
        Sprint-->>User: 入力フォーム表示

        User->>Sprint: リソース入力 (work_hours, meeting_hours)
        Note right of Sprint: 集中可能時間 = work_hours - meeting_hours
        Sprint->>Sprint: 期待ベロシティ計算 (メソッド実行)
        Sprint-->>User: target_point の目安を提示

        User->>Sprint: プラン確定 (target_point入力)
        Sprint->>DB: UPSERT INTO daily_reports (target_point, etc.)
        DB-->>Sprint: Success

    Note over User, DB: 3. スプリント範囲決定 (対象範囲メンテ)
        User->>Sprint: タスクを選択し「今日やる」に移動
        Note right of Sprint: status を 'backlog' -> 'todo' へ
        Sprint->>DB: UPDATE tasks SET status = 'todo', sort_order = ?
        DB-->>Sprint: Success

    Note over User, DB: 4. 段取り詳細化 (タスク詳細メンテ)
        User->>Sprint: タスク手順の編集
        User->>Sprint: 完了定義 (definition_of_done) の入力
        Sprint->>DB: UPDATE tasks SET procedures = ?, definition_of_done = ?
        DB-->>Sprint: Success
        Sprint-->>User: デイリーボード準備完了

```

## 3. 主要なデータ構造 (I/O)

このフェーズで扱う主要なデータ項目です。

| 項目 | 型 | 対応カラム / ロジック |
| --- | --- | --- |
| `target_point` | Integer | `daily_reports.target_point` |
| `work_hours` | Float | `daily_reports.work_hours` (入力値) |
| `meeting_hours` | Float | `daily_reports.meeting_hours` (入力値) |
| `status` | String | `tasks.status` ('backlog' ↔ 'todo') |
| `procedures` | Text | `tasks.procedures` (マークダウン) |

## 4. ロジック・制約事項（実装への落とし込み）

* **動的キャパシティ計算**: `daily_reports` モデルに `available_focus_time` メソッドを実装し、`(work_hours - meeting_hours)` を算出。これに基づき、推奨 `target_point` をフロントエンドに返す。
* **Enumの活用**: `tasks.status` は `_prefix: true` を設定し、`task.status_todo!` 等で直感的に遷移させる。
* **ポイントバリデーション**: `target_point` が過去の `actual_point` 平均値を大きく乖離する場合に警告を出す。

## 5. 画面設計メモ

* **プランニングView**: `daily_reports` の新規作成/更新フォームと、`tasks` のステータス一括更新（Drag & Drop）を一つの画面で行う。
* **マークダウンプレビュー**: `procedures`（手順）の入力中はリアルタイムでプレビューを表示し、段取りの具体化を促進する。
