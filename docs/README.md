# 猫占い日記 — ドキュメント

プロジェクトのドキュメント索引です。用途ごとにフォルダ分けしています。

## フォルダ構成

```
docs/
├── README.md          ← このファイル（索引）
├── planning/          企画・ロードマップ（最初に読む）
├── specs/             現行仕様・機能詳細（実装の正）
└── pr/                PRごとの変更メモ
```

## どれを読めばいい？

| 知りたいこと | 読むファイル |
|-------------|-------------|
| プロジェクト全体・MVP・将来計画 | [planning/rules.md](./planning/rules.md) |
| **今のアプリに何があるか** | [specs/features.md](./specs/features.md) |
| AI相談の処理フロー・API | [specs/ai-consultation.md](./specs/ai-consultation.md) |
| 特定PRで何を変えたか | [pr/](./pr/) 内の `pr-N-*.md` |

## ソース・素材

| 種類 | パス |
|------|------|
| 守護猫カード PNG | [assets/guardian-cats/](../assets/guardian-cats/) |

## ドキュメントの役割

### planning/ — 企画・設計

| ファイル | 内容 |
|----------|------|
| [rules.md](./planning/rules.md) | MVP企画書。ターゲット、機能一覧、ロードマップ、v1.0条件 |

**更新タイミング:** 企画変更・新フェーズ追加時

### specs/ — 現行仕様

| ファイル | 内容 |
|----------|------|
| [features.md](./specs/features.md) | **実装済み機能**の仕様書。画面・回数制限・データモデル |
| [ai-consultation.md](./specs/ai-consultation.md) | AI猫占い相談のロジック詳細 |

**更新タイミング:** 機能追加・仕様変更のたび（コードとセットで）

`features.md` は `planning/rules.md` との **差分（未実装含む）** も末尾に記載。

### pr/ — PR変更記録

| ファイル | 内容 |
|----------|------|
| [pr-4-memo-clear-after-fortune.md](./pr/pr-4-memo-clear-after-fortune.md) | PR4: 気分占いメモ送信後クリア |
| [pr-5-guardian-cat-png-assets.md](./pr/pr-5-guardian-cat-png-assets.md) | PR5: 守護猫カード PNG イラスト表示 |

**更新タイミング:** PR作成・マージ時に `pr-N-短い説明.md` を追加

## 読む順番（おすすめ）

1. [planning/rules.md](./planning/rules.md) — 全体像
2. [specs/features.md](./specs/features.md) — 今の実装
3. 必要に応じて [specs/ai-consultation.md](./specs/ai-consultation.md)
