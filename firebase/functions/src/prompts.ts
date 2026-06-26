export const FORTUNE_SYSTEM_PROMPT = `あなたは「猫占い日記」アプリのAI猫占い師です。
ユーザーの今日の気分と悩みに合わせて、占いメッセージを日本語で作成してください。

ルール:
- 猫口調で話す（語尾に「にゃ」を自然に使う）
- ポジティブで温かいトーン
- 不安を煽らない
- 医療行為・投資判断・法律判断の助言は禁止
- 占い文章は120文字以内
- 今日の一言は30文字以内
- 必ずJSONのみで返す`;

export const CHAT_SYSTEM_PROMPT = `あなたは「猫占い日記」アプリのAI猫占い師兼カウンセラーです。
ユーザーの悩みに寄り添い、日本語で返答してください。

ルール:
- 猫口調で話す（語尾に「にゃ」を自然に使う）
- 300文字以内
- 否定しない
- 共感する
- 具体的な行動提案を1つ入れる
- 医療行為・投資判断・法律判断の助言は禁止
- 返答本文のみを返す（JSON不要）`;

export function buildFortuneUserPrompt(input: {
  nickname?: string;
  mood: string;
  category: string;
  memo?: string;
  totalScore: number;
  loveScore: number;
  workScore: number;
  moneyScore: number;
  luckyAction: string;
}): string {
  const lines = [
    `ニックネーム: ${input.nickname ?? "ユーザー"}`,
    `今日の気分: ${input.mood}`,
    `悩みジャンル: ${input.category}`,
    `一言メモ: ${input.memo ?? "なし"}`,
    `総合運: ${input.totalScore}/5`,
    `恋愛運: ${input.loveScore}/5`,
    `仕事運: ${input.workScore}/5`,
    `金運: ${input.moneyScore}/5`,
    `ラッキー行動（アプリ側で決定済み）: ${input.luckyAction}`,
    "",
    '次のJSON形式で返してください: {"fortuneText":"...","oneLiner":"..."}',
  ];
  return lines.join("\n");
}

export function buildChatUserPrompt(input: {
  nickname?: string;
  concernCategory?: string;
  message: string;
}): string {
  const lines = [
    `ニックネーム: ${input.nickname ?? "ユーザー"}`,
    `よく相談するジャンル: ${input.concernCategory ?? "その他"}`,
    `相談内容: ${input.message}`,
  ];
  return lines.join("\n");
}
