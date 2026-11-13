import { useLayoutEffect, useRef, useState } from "react";
import type { FormEvent, KeyboardEvent } from "react";

interface Message {
  id: string;
  role: "user" | "assistant";
  text: string;
}

const suggestions = [
  { icon: "↗", title: "Say hello", detail: "Start with something simple", prompt: "Hello world!" },
  { icon: "✧", title: "Explore RAG42", detail: "Get to know your assistant", prompt: "What can RAG42 help me with?" },
  { icon: "≋", title: "Connect the dots", detail: "Learn how RAG works", prompt: "How does retrieval-augmented generation work?" },
];

const demoReply = "Hello world! I'm the RAG42 chat preview. Once the RAG and LLM are connected, this is where answers grounded in your knowledge will appear. For now, this is a fixed demo reply, not an AI-generated answer.";

export default function App() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [draft, setDraft] = useState("");
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const conversationRef = useRef<HTMLDivElement>(null);

  useLayoutEffect(() => {
    const input = inputRef.current;
    if (input) {
      input.style.height = "auto";
      input.style.height = `${Math.min(input.scrollHeight, 160)}px`;
    }
  }, [draft]);

  useLayoutEffect(() => {
    const conversation = conversationRef.current;
    if (conversation) conversation.scrollTop = conversation.scrollHeight;
  }, [messages]);

  function newChat() {
    setMessages([]);
    setDraft("");
    inputRef.current?.focus();
  }

  function sendMessage(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const text = draft.trim();
    if (!text) return;
    setMessages((previous) => [
      ...previous,
      { id: crypto.randomUUID(), role: "user", text },
      { id: crypto.randomUUID(), role: "assistant", text: demoReply },
    ]);
    setDraft("");
    inputRef.current?.focus();
  }

  function handleKeyDown(event: KeyboardEvent<HTMLTextAreaElement>) {
    if (event.key === "Enter" && !event.shiftKey && !event.nativeEvent.isComposing) {
      event.preventDefault();
      if (draft.trim()) event.currentTarget.form?.requestSubmit();
    }
  }

  return (
    <div className="app">
      <aside className="sidebar">
        <a className="brand" href="/" aria-label="RAG42 home"><span className="brand-icon">42</span> RAG42</a>
        <button className="new-chat" type="button" onClick={newChat}><span aria-hidden="true">+</span> New conversation</button>
        <div className="sidebar-note">
          <span className="eyebrow">YOUR KNOWLEDGE COMPANION</span>
          <p>A little curiosity.<br />A whole lot of possibility.</p>
        </div>
        <div className="workspace"><span className="workspace-icon">W</span><div>Local workspace<small>Development preview</small></div></div>
      </aside>
      <main>
        <header className="topbar">
          <span>Chat <span className="muted">/ New conversation</span></span>
          <button className="mobile-new-chat" type="button" aria-label="New conversation" onClick={newChat}>+</button>
          <span className="status"><span className="status-dot" /> Demo mode</span>
        </header>
        <div className="conversation" ref={conversationRef}>
          {messages.length === 0 && (
            <section className="welcome" aria-labelledby="welcome-title">
              <div className="welcome-icon" aria-hidden="true">42<span>✦</span></div>
              <p className="eyebrow">LESS SEARCHING. MORE UNDERSTANDING.</p>
              <h1 id="welcome-title">Hello, curious mind.</h1>
              <p className="intro">Your knowledge, in conversation.<br />Ask a question and let's make sense of it together.</p>
              <div className="suggestions" aria-label="Suggested messages">
                {suggestions.map((suggestion) => (
                  <button key={suggestion.title} type="button" onClick={() => {
                    setDraft(suggestion.prompt);
                    inputRef.current?.focus();
                  }}>
                    <span aria-hidden="true">{suggestion.icon}</span> {suggestion.title}
                    <span className="suggestion-detail">{suggestion.detail}</span>
                  </button>
                ))}
              </div>
            </section>
          )}
          <section className="messages" role="log" aria-label="Conversation" aria-live="polite" aria-relevant="additions">
            {messages.map((message) => (
              <article key={message.id} className={`message ${message.role}`}>
                <div className="avatar" aria-hidden="true">{message.role === "user" ? "Y" : "42"}</div>
                <div><h2>{message.role === "user" ? "You" : "RAG42 · Demo"}</h2><p>{message.text}</p></div>
              </article>
            ))}
          </section>
        </div>
        <div className="composer-area">
          <p className="demo-notice">Preview only · Messages stay in this page. No RAG or LLM is connected yet.</p>
          <form className="composer" onSubmit={sendMessage}>
            <label className="sr-only" htmlFor="message">Your message</label>
            <textarea ref={inputRef} id="message" name="message" rows={1} maxLength={4000} placeholder="Ask anything about your knowledge..." required value={draft} onChange={(event) => setDraft(event.target.value)} onKeyDown={handleKeyDown} />
            <button className="send" type="submit" aria-label="Send message" disabled={!draft.trim()}>↑</button>
          </form>
          <p className="composer-hint">Enter to send <span>·</span> Shift + Enter for a new line <span>·</span> RAG42</p>
        </div>
      </main>
    </div>
  );
}
