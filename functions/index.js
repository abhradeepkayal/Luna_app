const functions = require("firebase-functions");
const { GoogleAuth } = require("google-auth-library");
const fetch = require("node-fetch");

exports.chatWithGemini = functions.https.onRequest((req, res) => {
  // your chatbot logic — leave this as-is
});

exports.analyzeSpeech = functions.https.onRequest(async (req, res) => {
  const { user_input, context } = req.body;

  const prompt = `
User said: "${user_input}"
Context: ${context}

Please give a short and friendly compliment or feedback based on pronunciation, confidence, and appropriateness of the response.
Be encouraging and simple.
`;

  try {
    const auth = new GoogleAuth({
      scopes: "https://www.googleapis.com/auth/cloud-platform",
    });
    const client = await auth.getClient();
    const projectId = await auth.getProjectId();

    const accessToken = await client.getAccessToken();

    const response = await fetch(
      `https://us-central1-${projectId}.cloudfunctions.net/v1/projects/${projectId}/locations/us-central1/publishers/google/models/gemini-pro:predict`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken.token || accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          instances: [
            {
              prompt: prompt,
            },
          ],
          parameters: {
            temperature: 0.7,
            maxOutputTokens: 100,
          },
        }),
      }
    );

    const data = await response.json();
    const output =
  data && data.predictions && data.predictions[0] && data.predictions[0].content
    ? data.predictions[0].content
    : "Great effort!";
    return res.status(200).send(output);
  } catch (err) {
    console.error("Error calling Gemini:", err);
    return res.status(500).send("AI Error");
  }
});