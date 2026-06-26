# AI猫占い相談 ロジック設計書

猫占い日記における **AI相談（チャット）** の処理フローと実装方針をまとめたドキュメントです。

---

## 1. 概要

ユーザーが悩みを入力すると、AI猫占い師が猫口調で返答する機能。

| 項目 | 内容 |
|------|------|
| 画面 | `ChatConsultationView` |
| 保存 | SwiftData `ChatMessage` |
| AI API | Firebase Cloud Functions → OpenAI `gpt-4o-mini` |
| オフライン時 | 固定のフォールバック文を返す |

---

## 2. 処理フロー

```
ユーザーがメッセージ送信
        ↓
回数制限チェック（UsageLimitService）
        ↓ 上限ならエラー表示・送信不可
回数を1消費
        ↓
入力欄をクリア
        ↓
ユーザーメッセージを SwiftData に保存
        ↓
AIバックエンド接続あり？
   ├─ YES → Cloud Functions /chatConsult を呼び出し
   │         └─ 失敗時はフォールバック文
   └─ NO  → フォールバック文
        ↓
AI返答を SwiftData に保存
        ↓
チャット画面に表示
```

---

## 3. 回数制限

`UsageLimitService` が送信前に判定する。

| プラン | 制限 |
|--------|------|
| 無料 | 通算 **3回**（`freeTrialUsed`） |
| プレミアム | **月30回**（`premiumChatUsed`、月初リセット） |
| チケット | 通常枠消費後に `ticketBalance` から消費 |

**1回のユーザー送信 = 相談1回** としてカウントする（AI応答の成否に関わらず消費）。

---

## 4. AI 接続の判定

`AIConfig.isBackendConfigured` で判定。

- 環境変数 `AI_BACKEND_BASE_URL` または Info.plist の同名キーが設定されている → AI接続モード
- 未設定 → オフラインモード（フォールバック文のみ）

チャット画面上部に **「AI接続中」** バッジが表示される（接続時のみ）。

---

## 5. リクエスト内容（iOS → Cloud Functions）

エンドポイント: `POST /chatConsult`

```json
{
  "nickname": "みけちゃん",
  "concernCategory": "恋愛",
  "message": "彼氏と喧嘩した",
  "history": [
    { "role": "user", "message": "..." },
    { "role": "assistant", "message": "..." }
  ]
}
```

| フィールド | 説明 |
|-----------|------|
| nickname | プロフィールのニックネーム |
| concernCategory | よく相談するジャンル |
| message | 今回の相談内容 |
| history | 直近 **8件** の会話履歴（今回の送信前） |

---

## 6. AI プロンプトルール（Cloud Functions）

`firebase/functions/src/prompts.ts` で定義。

### システムプロンプトの条件

- 猫口調（語尾に「にゃ」）
- **300文字以内**
- 否定しない
- 共感する
- 具体的な行動提案を **1つ** 入れる
- 医療・投資・法律の助言は禁止

### モデル

- `gpt-4o-mini`（コスト抑制）
- `max_tokens: 400`
- 返答は本文のみ（JSON不要）

---

## 7. 会話履歴の扱い

| 保存先 | 用途 |
|--------|------|
| SwiftData `ChatMessage` | アプリ内表示・再起動後の復元 |
| API `history` | 文脈を踏まえた AI 返答生成 |

履歴は送信 **前** のメッセージから最大8件を API に渡す。  
今回送ったユーザーメッセージは `history` には含めず、`message` フィールドで渡す。

---

## 8. オフライン時のフォールバック

AI未設定・APIエラー時は以下の固定文を返す。

> うんうん、それはつらかったにゃ。今日は自分を責めすぎないで、ゆっくり休むのがいいにゃ。

画面上部にエラー文言を表示:

> AIに接続できなかったため、オフライン応答を表示しています

---

## 9. 関連ファイル

| ファイル | 役割 |
|----------|------|
| `Views/Chat/ChatConsultationView.swift` | UI・送信処理 |
| `Services/AIService.swift` | API 呼び出し |
| `Services/AIConfig.swift` | バックエンド URL 設定 |
| `Services/UsageLimitService.swift` | 回数制限 |
| `Models/ChatMessage.swift` | メッセージ永続化 |
| `firebase/functions/src/index.ts` | `/chatConsult` エンドポイント |
| `firebase/functions/src/prompts.ts` | プロンプト定義 |
| `firebase/functions/src/openai.ts` | OpenAI 呼び出し |

---

## 10. 占いとの違い

| | 占い（気分モード） | AI相談 |
|--|-------------------|--------|
| 入力 | 気分・ジャンル・メモ | 自由テキスト |
| 出力 | スコア + 占い文 + ラッキー行動 | 会話形式の返答 |
| 回数 | 日次（無料1回/プレミアム3回） | 通算 or 月次 |
| AI生成 | 占い文章のみ | 返答全文 |
| ログ | `DailyLog` に保存 | `ChatMessage` に保存 |

---

## 11. 今後の拡張（未実装）

- [ ] StoreKit 課金との連携（Phase5）
- [ ] Firebase Anonymous Auth によるユーザー識別
- [ ] Firestore への会話同期
- [ ] 相談内容に応じたフォールバック文のバリエーション
- [ ] 長期記憶（v2.0）
