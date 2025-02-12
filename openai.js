import OpenAI from "openai";
const openai = new OpenAI();

const completion = await openai.chat.completions.create({
    model: "gpt-4o",
    messages: [
        { role: "film producer", content: "you are a producer and you are provided with ideas, ." },
        {
            role: "user",
            content: &{topics},
        },
    ],
    store: true,
});

console.log(completion.choices[0].message);