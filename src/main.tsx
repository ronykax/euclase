import { createRoot } from "react-dom/client";

import "./index.css";
import "@fontsource-variable/geist";
import "@fontsource-variable/geist-mono";

import { App } from "./app";

const root = document.querySelector("#root");

if (!root) {
  throw new Error("no root");
}

createRoot(root).render(<App />);
