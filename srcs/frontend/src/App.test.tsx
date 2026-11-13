import { fireEvent, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import App from "./App";

describe("demo chat", () => {
  it("rejects empty messages and sends a suggested message with a labeled demo reply", async () => {
    const user = userEvent.setup();
    render(<App />);
    const input = screen.getByRole("textbox", { name: "Your message" });
    const send = screen.getByRole("button", { name: "Send message" });
    expect(send).toBeDisabled();
    await user.type(input, "   ");
    expect(send).toBeDisabled();
    fireEvent.submit(input.closest("form")!);
    expect(within(screen.getByRole("log")).queryAllByRole("article")).toHaveLength(0);
    await user.click(screen.getByRole("button", { name: /Say hello/ }));
    expect(input).toHaveValue("Hello world!");
    await user.keyboard("{Enter}");
    const log = screen.getByRole("log");
    expect(within(log).getAllByRole("article")).toHaveLength(2);
    expect(within(log).getByText("Hello world!")).toBeInTheDocument();
    expect(within(log).getByText(/fixed demo reply/)).toBeInTheDocument();
    expect(input).toHaveValue("");
    expect(input).toHaveFocus();
  });

  it("supports multiline messages, renders HTML as text and resets the conversation", async () => {
    const user = userEvent.setup();
    render(<App />);
    const input = screen.getByRole("textbox", { name: "Your message" });
    await user.type(input, "<img src=x onerror=alert(1)>");
    await user.keyboard("{Shift>}{Enter}{/Shift}second line");
    expect(input).toHaveValue("<img src=x onerror=alert(1)>\nsecond line");
    expect(within(screen.getByRole("log")).queryAllByRole("article")).toHaveLength(0);
    await user.click(screen.getByRole("button", { name: "Send message" }));
    expect(screen.getByRole("log").querySelector("img")).toBeNull();
    expect(within(screen.getByRole("log")).getByText(/<img src=x/)).toBeInTheDocument();
    await user.click(screen.getAllByRole("button", { name: /New conversation/ })[0]!);
    expect(screen.getByRole("log")).toBeEmptyDOMElement();
    expect(screen.getByRole("heading", { name: "Hello, curious mind." })).toBeVisible();
    expect(input).toHaveValue("");
  });
});
