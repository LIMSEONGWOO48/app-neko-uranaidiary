import cors from "cors";
import express from "express";
import { onRequest } from "firebase-functions/v2/https";
import {
  buildChatUserPrompt,
  buildFortuneUserPrompt,
  CHAT_SYSTEM_PROMPT,
  FORTUNE_SYSTEM_PROMPT,
} from "./prompts";
import { createOpenAIClient, generateChatReply, generateFortuneText } from "./openai";

const app = express();
app.use(cors({ origin: true }));
app.use(express.json({ limit: "32kb" }));

app.get("/health", (_req, res) => {
  res.json({ ok: true });
});

app.post("/generateFortune", async (req, res) => {
  try {
    const {
      nickname,
      mood,
      category,
      memo,
      totalScore,
      loveScore,
      workScore,
      moneyScore,
      luckyAction,
    } = req.body ?? {};

    if (!mood || !category || !luckyAction) {
      res.status(400).json({ error: "mood, category, and luckyAction are required" });
      return;
    }

    const client = createOpenAIClient();
    const userPrompt = buildFortuneUserPrompt({
      nickname,
      mood,
      category,
      memo,
      totalScore: Number(totalScore ?? 3),
      loveScore: Number(loveScore ?? 3),
      workScore: Number(workScore ?? 3),
      moneyScore: Number(moneyScore ?? 3),
      luckyAction,
    });

    const result = await generateFortuneText(
      client,
      FORTUNE_SYSTEM_PROMPT,
      userPrompt
    );

    res.json(result);
  } catch (error) {
    console.error("generateFortune failed", error);
    res.status(500).json({ error: "Failed to generate fortune" });
  }
});

app.post("/chatConsult", async (req, res) => {
  try {
    const { nickname, concernCategory, message, history } = req.body ?? {};

    if (!message || typeof message !== "string") {
      res.status(400).json({ error: "message is required" });
      return;
    }

    const safeHistory = Array.isArray(history)
      ? history
          .filter(
            (item) =>
              item &&
              (item.role === "user" || item.role === "assistant") &&
              typeof item.message === "string"
          )
          .slice(-8)
      : [];

    const client = createOpenAIClient();
    const userPrompt = buildChatUserPrompt({
      nickname,
      concernCategory,
      message,
    });

    const reply = await generateChatReply(
      client,
      CHAT_SYSTEM_PROMPT,
      safeHistory,
      userPrompt
    );

    res.json({ reply });
  } catch (error) {
    console.error("chatConsult failed", error);
    res.status(500).json({ error: "Failed to generate chat reply" });
  }
});

export const api = onRequest(
  {
    region: "asia-northeast1",
    secrets: ["OPENAI_API_KEY"],
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  app
);
