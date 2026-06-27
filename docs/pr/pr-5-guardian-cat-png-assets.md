# PR5: 守護猫カードを PNG イラスト + テキスト表示に変更

## Summary

猫カード（今日の猫カード / 猫カードを引く）の守護猫表示を、絵文字から **PNG イラスト + テキスト** に置き換えた。  
16種の守護猫素材を `Assets.xcassets` に登録し、開封画面・ホームのプレビューで共通コンポーネント `GuardianCatCardView` を使う。

## 背景・課題

- PR2 で守護猫16種のデッキは実装済みだったが、表示は絵文字（🐱 など）だった
- 企画・素材として `assets/guardian-cats/` に PNG を用意したため、アプリ内でもイラスト表示に統一したい

## 変更内容

### 1. 守護猫 PNG アセットの追加

- `assets/guardian-cats/` に16種の PNG を配置（ソース素材）
- `Assets.xcassets` に `GuardianMikeNeko` 〜 `GuardianSoraNeko` の imageset を追加
- 黒背景は透明化して UI のグラデーション背景に馴染むようにした

| 守護猫 | アセット名 | ソース PNG |
|--------|-----------|-----------|
| みけ猫 | `GuardianMikeNeko` | `みけ猫.png` |
| しろ猫 | `GuardianShiroNeko` | `しろ猫.png` |
| くろ猫 | `GuardianKuroNeko` | `くろ猫.png` |
| トラ猫 | `GuardianToraNeko` | `とら猫.png` |
| ペルシャ猫 | `GuardianPersianNeko` | `ペルシャ猫.png` |
| サバ猫 | `GuardianSabaNeko` | `さば猫.png` |
| ルナ猫 | `GuardianLunaNeko` | `ルナ猫.png` |
| スター猫 | `GuardianStarNeko` | `スター猫.png` |
| シャム猫 | `GuardianSiamNeko` | `シャム猫.png` |
| マーブル猫 | `GuardianMarbleNeko` | `マーブル猫.png` |
| ミスト猫 | `GuardianMistNeko` | `ミスト猫.png` |
| ガーデン猫 | `GuardianGardenNeko` | `ガーデン猫.png` |
| クローバー猫 | `GuardianCloverNeko` | `クローバー猫.png` |
| オーロラ猫 | `GuardianAuroraNeko` | `オーロラ猫.png` |
| パール猫 | `GuardianPearlNeko` | `パール猫.png` |
| ソラ猫 | `GuardianSoraNeko` | `ソラ猫.png` |

### 2. データモデルの変更

- `CatCardResult.cardEmoji` → `imageAssetName` に変更
- `CatCardGenerator` の16種定義を `(name, asset, theme)` 形式に更新

### 3. UI コンポーネント追加

- `GuardianCatCardView`（`AppTheme.swift`）を追加
  - PNG イラスト + 守護猫名 + キーワード（任意）を表示
  - `imageHeight` / `showName` でサイズ・ラベル表示を調整可能

### 4. 画面の更新

- **CatCardDrawView** — カード開封後に `GuardianCatCardView` で表示（絵文字削除）
- **HomeHubView** — 今日選んだ猫カードのプレビューを小さい PNG + 名前・キーワードに変更

### 5. 仕様書・索引の更新

- `docs/specs/features.md` — 守護猫表から絵文字を削除、アセット名列を追加
- `docs/README.md` — 守護猫素材パス・PR索引を追記

## 変更ファイル

| ファイル | 変更 |
|----------|------|
| `NekoUranaiDiary/.../Services/CatCardGenerator.swift` | `imageAssetName` マッピング |
| `NekoUranaiDiary/.../Resources/AppTheme.swift` | `GuardianCatCardView` 追加 |
| `NekoUranaiDiary/.../Views/Home/CatCardDrawView.swift` | 開封 UI を PNG 表示に |
| `NekoUranaiDiary/.../Views/Home/HomeHubView.swift` | ホームプレビューを PNG 表示に |
| `NekoUranaiDiary/.../Assets.xcassets/Guardian*.imageset/` | 16種 PNG アセット |
| `assets/guardian-cats/*.png` | ソース素材16枚 |
| `docs/specs/features.md` | 守護猫仕様の更新 |
| `docs/README.md` | 索引更新 |

## 動作確認（Test plan）

- [ ] ホーム → 「猫カードを引く」→ 5枚から1枚選択 → 開封後に PNG + 名前 + キーワードが表示される
- [ ] 絵文字がどこにも表示されない（開封画面・ホームプレビュー）
- [ ] カードを選んだあとホームに戻る → 小さい PNG + 名前・キーワードのプレビューが表示される
- [ ] 日をまたぐとデッキが変わり、別の守護猫 PNG が表示される
- [ ] 「占い結果を詳しく見る」→ 従来どおり詳細占い画面へ遷移する
- [ ] 16種すべての守護猫が正しいイラストで表示される（特にみけ猫・トラ猫・サバ猫）

## ブランチ名

```
feature/cat-card-guardian-images
```

（代替: `feature/guardian-cat-png-assets`）

## 関連PR

| PR | 内容 |
|----|------|
| PR1 | 機能説明 `docs/specs/features.md` 追加 |
| PR2 | 猫カード・守護猫16種・デッキUI |
| PR3 | 気分モードのミャオイラスト6種 |
| PR4 | 気分占いメモ送信後クリア |
| **PR5** | **守護猫 PNG イラスト表示（本修正）** |
