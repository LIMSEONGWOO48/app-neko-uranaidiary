import OpenAI from "openai";

export function createOpenAIClient(): OpenAI {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is not configured");
  }
  return new OpenAI({ apiKey });
}

export async function generateFortuneText(
  client: OpenAI,
  systemPrompt: string,
  userPrompt: string
): Promise<{ fortuneText: string; oneLiner: string }> {
  const response = await client.chat.completions.create({
    model: "gpt-4o-mini",
    temperature: 0.8,
    response_format: { type: "json_object" },
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userPrompt },
    ],
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("Empty AI response");
  }

  const parsed = JSON.parse(content) as {
    fortuneText?: string;
    oneLiner?: string;
  };

  const fortuneText = parsed.fortuneText?.trim();
  const oneLiner = parsed.oneLiner?.trim();

  if (!fortuneText || !oneLiner) {
    throw new Error("Invalid AI response format");
  }

  return { fortuneText, oneLiner };
}

export async function generateChatReply(
  client: OpenAI,
  systemPrompt: string,
  history: Array<{ role: "user" | "assistant"; message: string }>,
  userPrompt: string
): Promise<string> {
  const messages: OpenAI.Chat.ChatCompletionMessageParam[] = [
    { role: "system", content: systemPrompt },
    ...history.map((item) => ({
      role: item.role,
      content: item.message,
    })),
    { role: "user", content: userPrompt },
  ];

  const response = await client.chat.completions.create({
    model: "gpt-4o-mini",
    temperature: 0.7,
    max_tokens: 400,
    messages,
  });

  const content = response.choices[0]?.message?.content?.trim();
  if (!content) {
    throw new Error("Empty AI response");
  }

  return content.slice(0, 300);
}
