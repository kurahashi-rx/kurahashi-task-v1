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
    User->>App: プランニング：キャパシティと目標Ptを設定する
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
```mermaid
sequenceDiagram
    autonumber
    actor User as ユーザー
    participant View_Backlog as バックログ画面
    participant View_Sprint as プランニング画面
    participant View_Sprint as スプリント画面

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






