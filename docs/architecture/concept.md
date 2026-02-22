# アプリケーションコンセプト

## 用語定義（ドメイン）
- **実績ポイント**: 消化タスクから算出されるその日の生産性指標。
- **AIコーチング**: 実績に基づき、AIが翌日のアクションプランを提案するプロセス。
- **タスク粒度**: 思考を止めずに実行できるよう細分化された作業単位。

## 業務フロー
```mermaid
sequenceDiagram
    autonumber
    actor User as ユーザー
    participant App as 倉橋タスク (System)
    participant AI as AIコーチ

    Note over User, AI: 【デイリースクラム】
    User->>App: バックログメンテ：現状をバックログへ反映する
    User->>App: デイリープランニング：キャパシティと目標Ptを設定する
    User->>App: スプリントタスク設定：プランニング結果に基づき、当日の対象タスクを選択する
    User->>App: タスクの段取り検討：タスクの段取りを詳細化する

    Note over User, AI: 【スプリント実行】
    User->>User: タスク実行：詳細化した段取りに従い、タスクを実行する
    User->>App: 実行結果登録：完了タスクの消し込み、計画変更などを反映する

    Note over User, AI: 【振り返り】
    User->>App: ベロシティ評価：予実比較や過去経緯を振り返り、結果を登録する
    User->>AI: フィードバック：振り返り結果の評価を依頼する
    AI-->>User: フィードバック返却
    User->>App: Tryの設定：ネクストアクションを策定し、登録する
    User->>User: 改善アクション：実際にネクストアクションを実施する

```

### デイリースクラム

タスク管理ツールの画面設計前にシナリオを整理している
シーケンス図で整理しているので続きを生成してほしい

■記載途中のシナリオ
```mermaid
sequenceDiagram
    autonumber
    actor User as ユーザー
    participant View_Task as タスク画面
    participant View_D_Plan as デイリープラン画面

    Note over User, View_Task: 【バックログメンテ】
    User->>View_Task: 【R】現在のタスクを確認する
    View_Task-->>User: タスク一覧
    User->>View_Task: 【C/D】状況に応じてバックログ応現を反映
    User->>View_Task: 【U】詳細化や変更内容を反映

    Note over User, View_D_Plan: 【デイリープランニング】

```
```mermaid
sequenceDiagram
    autonumber
    actor User as ユーザー
    participant View_Task as タスク画面
    participant View_D_Plan as デイリープラン画面
    participant DB as データベース

    Note over User, View_Task: 【バックログメンテ】
    User->>View_Task: 【R】現在のタスクを確認する
    View_Task-->>User: タスク一覧
    User->>View_Task: 【C/D】状況に応じてバックログを反映
    User->>View_Task: 【U】詳細化や変更内容を反映

    Note over User, View_D_Plan: 【デイリープランニング】
    User->>View_D_Plan: デイリーレポ画面を開く
    View_D_Plan->>DB: バックログ・過去の消化傾向を取得
    DB-->>View_D_Plan: データ返却
    
    rect rgb(240, 240, 240)
    Note right of User: ステップ1：目標設定
    User->>View_D_Plan: 【C/U】今日のキャパシティと目標Ptを登録
    View_D_Plan-->>User: 入力内容の反映（残ポイントの可視化）
    end

    rect rgb(230, 240, 255)
    Note right of User: ステップ2：スプリント対象（今日やる事）の選択
    User->>View_D_Plan: 【U】バックログから対象タスクを選択（紐付け）
    View_D_Plan-->>User: 合計Ptを更新・目標との差分を表示
    end

    rect rgb(240, 255, 240)
    Note right of User: ステップ3：タスクの詳細化
    User->>View_D_Plan: 【U】選択したタスクを分解（サブタスク化/見積修正）
    View_D_Plan->>DB: 更新内容の保存
    View_D_Plan-->>User: プラン完了・実行フェーズへ
    end

```




### スプリント実行
```mermaid

```

### 昨日の振り返り
```mermaid

```


- タスクメンテ
  - タスク一覧画面での編集
    - 新規追加
    - 削除
    - 編集
      - 名称や内容などの詳細メンテ
  - デイリースクラム画面
    - 一覧メンテ
    - 優先度
    - ポイント変更






